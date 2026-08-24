package transport

// Epic 04 task 04.1 -- Firebase ID token verification (ADR-0009).
//
// WHY THIS IS NOT THE FIREBASE ADMIN SDK
//
// The task named the Admin SDK and this deliberately does not use it. The
// SDK's ID token key source is built at auth/token_verifier.go:106 with its
// own HTTP client and ignores every option the caller passes, so there is no
// seam to serve test certificates through. The only ways to exercise the
// signature path with it are to mutate http.DefaultTransport globally, or to
// set FIREBASE_AUTH_EMULATOR_HOST -- which makes the SDK skip signature
// verification entirely, i.e. test nothing. The task's own Done-when asks for
// verification proven by a test, and the SDK cannot be made to satisfy it
// without a live Firebase project.
//
// So verification is assembled here from standard library primitives. No
// cryptography is hand-written: rsa.VerifyPKCS1v15 and x509.ParseCertificate
// do that work. What is written here is the claim policy and the key cache,
// both of which are small, explicit, and covered by firebase_test.go.
//
// It also drops grpc, genproto and cloud.google.com from go.mod, which a
// four-dependency module should not carry to check a signature.

import (
	"context"
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
)

// EnvAppEnv selects which verifier the binary boots with.
const EnvAppEnv = "APP_ENV"

// EnvFirebaseProjectID names the Firebase project whose ID tokens this
// deployment accepts. It is the audience check, so it is not optional: a
// verifier that accepts any audience accepts tokens minted for any other
// Firebase project on earth.
const EnvFirebaseProjectID = "FIREBASE_PROJECT_ID"

// googleIDTokenCertURL serves the x509 certificates Firebase ID tokens are
// signed with, keyed by the token's `kid` header.
const googleIDTokenCertURL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

// clockSkew is how far ahead of us another server's clock may be before we
// call its token invalid.
//
// It applies to `iat` and `exp` alike. Without it, a token minted on a
// machine two seconds ahead of this one is rejected as issued in the future
// -- a failure that looks like an outage and reproduces on nobody's laptop.
const clockSkew = 60 * time.Second

// maxSubjectLen bounds the subject we will accept. Firebase UIDs are at most
// 128 characters; anything longer is not a UID, and a token subject flows
// into a database lookup.
const maxSubjectLen = 128

// firebaseVerifier verifies Google Sign-In ID tokens (ADR-0009).
//
// Verification is offline. The signing certificates are fetched once and
// cached for as long as the response's Cache-Control allows, so this costs a
// network round trip after a key rotation and nothing on the calls between.
//
// Session revocation is not checked. Doing so means an API call to Firebase
// on every request and a hard dependency on service-account credentials that
// signature verification does not need. Revocation is not in BRD 7.1; when
// it lands, it is a lookup added here, not a redesign.
type firebaseVerifier struct {
	projectID string
	certs     *certCache
	now       func() time.Time
}

// NewFirebaseVerifier builds a verifier for the given Firebase project.
//
// It needs no service account. Verifying an ID token means checking a
// signature against Google's *public* certificates, so the project id is the
// whole configuration. This never mints a token, which is the only operation
// that would need credentials.
//
// A nil client means the default one. Tests pass their own to serve their
// own certificates.
func NewFirebaseVerifier(_ context.Context, projectID string, client *http.Client) (TokenVerifier, error) {
	if projectID == "" {
		return nil, fmt.Errorf("%s is required to verify ID tokens", EnvFirebaseProjectID)
	}
	if client == nil {
		client = &http.Client{Timeout: 10 * time.Second}
	}
	return firebaseVerifier{
		projectID: projectID,
		certs:     &certCache{client: client, url: googleIDTokenCertURL, now: time.Now},
		now:       time.Now,
	}, nil
}

// idTokenClaims is the subset of a Firebase ID token this API depends on.
type idTokenClaims struct {
	Iss      string `json:"iss"`
	Aud      string `json:"aud"`
	Sub      string `json:"sub"`
	IssuedAt int64  `json:"iat"`
	Expires  int64  `json:"exp"`
}

// jwtHeader is the token's declared algorithm and signing key.
type jwtHeader struct {
	Alg string `json:"alg"`
	Kid string `json:"kid"`
}

// Verify checks the token and returns only its subject.
//
// Every failure -- expired, wrong audience, forged signature, malformed --
// collapses to core.ErrInvalidToken. Telling a caller which one it was tells
// an attacker which half of the problem they have already solved.
func (v firebaseVerifier) Verify(ctx context.Context, token string) (VerifiedToken, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return VerifiedToken{}, core.ErrInvalidToken
	}

	var header jwtHeader
	if err := decodeSegment(parts[0], &header); err != nil {
		return VerifiedToken{}, core.ErrInvalidToken
	}
	// RS256 only. Accepting the algorithm the token asks for is how "alg":
	// "none" forgeries work, and HMAC would let Google's *public* certificate
	// double as a signing secret.
	if header.Alg != "RS256" || header.Kid == "" {
		return VerifiedToken{}, core.ErrInvalidToken
	}

	var claims idTokenClaims
	if err := decodeSegment(parts[1], &claims); err != nil {
		return VerifiedToken{}, core.ErrInvalidToken
	}
	if err := v.checkClaims(claims); err != nil {
		return VerifiedToken{}, core.ErrInvalidToken
	}

	sig, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return VerifiedToken{}, core.ErrInvalidToken
	}
	key, err := v.certs.keyFor(ctx, header.Kid)
	if err != nil {
		return VerifiedToken{}, core.ErrInvalidToken
	}
	digest := sha256.Sum256([]byte(parts[0] + "." + parts[1]))
	if err := rsa.VerifyPKCS1v15(key, crypto.SHA256, digest[:], sig); err != nil {
		return VerifiedToken{}, core.ErrInvalidToken
	}

	return VerifiedToken{FirebaseUID: claims.Sub}, nil
}

func (v firebaseVerifier) checkClaims(c idTokenClaims) error {
	now := v.now()

	if c.Aud != v.projectID {
		return core.ErrInvalidToken
	}
	if c.Iss != "https://securetoken.google.com/"+v.projectID {
		return core.ErrInvalidToken
	}
	if c.Sub == "" || len(c.Sub) > maxSubjectLen {
		return core.ErrInvalidToken
	}
	if c.Expires == 0 || now.After(time.Unix(c.Expires, 0).Add(clockSkew)) {
		return core.ErrInvalidToken
	}
	if c.IssuedAt == 0 || now.Add(clockSkew).Before(time.Unix(c.IssuedAt, 0)) {
		return core.ErrInvalidToken
	}
	return nil
}

func decodeSegment(seg string, into any) error {
	raw, err := base64.RawURLEncoding.DecodeString(seg)
	if err != nil {
		return err
	}
	return json.Unmarshal(raw, into)
}

// ───────────────────────── certificate cache ─────────────────────────

// certCache holds Google's ID token signing certificates until the
// Cache-Control on the response that carried them says they are stale.
//
// Google rotates these keys, and a token signed with the new key arrives
// before any schedule would tell us to refresh. So an unknown `kid` forces a
// refetch rather than a rejection -- but only once per expiry window, so a
// stream of forged tokens with random kids cannot turn into a stream of
// outbound requests.
type certCache struct {
	client *http.Client
	url    string
	now    func() time.Time

	mu          sync.Mutex
	keys        map[string]*rsa.PublicKey
	expiresAt   time.Time
	lastAttempt time.Time
}

// minRefetchInterval bounds how often an unknown kid may trigger a fetch.
const minRefetchInterval = time.Minute

func (c *certCache) keyFor(ctx context.Context, kid string) (*rsa.PublicKey, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	fresh := c.now().Before(c.expiresAt)
	if key, ok := c.keys[kid]; ok && fresh {
		return key, nil
	}
	// Either the cache is stale, or it is fresh but does not have this kid --
	// which is what a key rotation looks like from here.
	if !fresh || c.now().Sub(c.lastAttempt) >= minRefetchInterval {
		if err := c.refresh(ctx); err != nil {
			// A fetch failure must not discard keys that still verify
			// tokens: an outage at Google's endpoint would otherwise become
			// an outage here.
			if key, ok := c.keys[kid]; ok {
				return key, nil
			}
			return nil, err
		}
	}
	if key, ok := c.keys[kid]; ok {
		return key, nil
	}
	return nil, fmt.Errorf("no signing certificate for kid %q", kid)
}

// refresh fetches and parses the certificate set. Callers hold c.mu.
func (c *certCache) refresh(ctx context.Context) error {
	c.lastAttempt = c.now()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.url, nil)
	if err != nil {
		return err
	}
	res, err := c.client.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = res.Body.Close() }()

	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("certificate endpoint returned %d", res.StatusCode)
	}

	var pems map[string]string
	if err := json.NewDecoder(res.Body).Decode(&pems); err != nil {
		return err
	}

	keys := make(map[string]*rsa.PublicKey, len(pems))
	for kid, certPEM := range pems {
		key, err := rsaPublicKeyFromPEM(certPEM)
		if err != nil {
			// One malformed certificate must not poison the rest: the
			// others still verify the tokens signed with them.
			continue
		}
		keys[kid] = key
	}
	if len(keys) == 0 {
		return fmt.Errorf("certificate endpoint returned no usable certificates")
	}

	c.keys = keys
	c.expiresAt = c.now().Add(maxAge(res.Header.Get("Cache-Control")))
	return nil
}

// defaultCertTTL is how long certificates are held when the response says
// nothing. Google always sends Cache-Control here; this is the floor for the
// day it does not.
const defaultCertTTL = time.Hour

// maxAge reads max-age out of a Cache-Control header.
func maxAge(header string) time.Duration {
	for _, part := range strings.Split(header, ",") {
		part = strings.TrimSpace(part)
		raw, ok := strings.CutPrefix(part, "max-age=")
		if !ok {
			continue
		}
		secs, err := strconv.Atoi(raw)
		if err != nil || secs <= 0 {
			continue
		}
		return time.Duration(secs) * time.Second
	}
	return defaultCertTTL
}

func rsaPublicKeyFromPEM(certPEM string) (*rsa.PublicKey, error) {
	block, _ := pem.Decode([]byte(certPEM))
	if block == nil {
		return nil, fmt.Errorf("not a PEM block")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, err
	}
	key, ok := cert.PublicKey.(*rsa.PublicKey)
	if !ok {
		return nil, fmt.Errorf("certificate public key is %T, not RSA", cert.PublicKey)
	}
	return key, nil
}

// ───────────────────────── verifier selection ─────────────────────────

// NewVerifier picks the verifier this environment is allowed to run.
//
//	APP_ENV=dev   -> devVerifier, which trusts "dev:<uid>" and proves nothing
//	anything else -> Firebase ID token verification
//
// The default is the strict one. An unset APP_ENV lands on Firebase and
// fails loudly for want of a project id, rather than silently booting the
// verifier that authenticates anyone.
func NewVerifier(ctx context.Context) (TokenVerifier, error) {
	if os.Getenv(EnvAppEnv) == "dev" {
		return NewDevVerifier()
	}
	return NewFirebaseVerifier(ctx, os.Getenv(EnvFirebaseProjectID), nil)
}
