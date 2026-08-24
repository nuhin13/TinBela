package transport

// Epic 04 task 04.1 -- Firebase ID token verification.
//
// These tests mint REAL RS256 tokens with a locally generated key and serve
// the matching certificate through an injected HTTP client. So the signature
// path, the certificate lookup by `kid`, and every claim rule are exercised
// against the actual SDK -- no Firebase project, no network, no mock of the
// thing under test.
//
// What they cannot cover is a token Google actually minted. That is the
// "real token" half of the task's Done-when and it needs a live project.

import (
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
)

const (
	testProjectID = "tinbela-test"
	testKeyID     = "test-key-1"

	// The endpoint the Firebase SDK fetches ID token signing certificates
	// from. Hard-coded in the SDK, so hard-coded here too.
	certURL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
)

func TestFirebaseVerifierAcceptsAValidToken(t *testing.T) {
	ctx := context.Background()
	signer := newTestSigner(t)
	v := newTestVerifier(t, ctx, testProjectID, signer)

	token := signer.mint(t, claims{
		Iss:      "https://securetoken.google.com/" + testProjectID,
		Aud:      testProjectID,
		Sub:      "firebase-uid-abc",
		IssuedAt: time.Now().Add(-time.Minute).Unix(),
		Expires:  time.Now().Add(time.Hour).Unix(),
		AuthTime: time.Now().Add(-time.Minute).Unix(),
	})

	got, err := v.Verify(ctx, token)
	if err != nil {
		t.Fatalf("Verify() on a valid token: %v", err)
	}
	if got.FirebaseUID != "firebase-uid-abc" {
		t.Errorf("FirebaseUID = %q, want %q", got.FirebaseUID, "firebase-uid-abc")
	}
}

// Every rejection must look identical to the caller. A verifier that
// distinguishes "expired" from "forged" tells an attacker which half of the
// problem they solved.
func TestFirebaseVerifierRejects(t *testing.T) {
	ctx := context.Background()
	signer := newTestSigner(t)
	other := newTestSigner(t)
	v := newTestVerifier(t, ctx, testProjectID, signer)

	valid := func() claims {
		return claims{
			Iss:      "https://securetoken.google.com/" + testProjectID,
			Aud:      testProjectID,
			Sub:      "firebase-uid-abc",
			IssuedAt: time.Now().Add(-time.Minute).Unix(),
			Expires:  time.Now().Add(time.Hour).Unix(),
			AuthTime: time.Now().Add(-time.Minute).Unix(),
		}
	}

	tests := []struct {
		name  string
		token func() string
	}{
		{
			// A token for another Firebase project. Without the audience
			// check, anyone with any Firebase project could mint a token
			// this API would accept.
			name: "wrong audience",
			token: func() string {
				c := valid()
				c.Aud = "someone-elses-project"
				return signer.mint(t, c)
			},
		},
		{
			name: "wrong issuer",
			token: func() string {
				c := valid()
				c.Iss = "https://securetoken.google.com/someone-elses-project"
				return signer.mint(t, c)
			},
		},
		{
			name: "expired",
			token: func() string {
				c := valid()
				c.IssuedAt = time.Now().Add(-2 * time.Hour).Unix()
				c.AuthTime = time.Now().Add(-2 * time.Hour).Unix()
				c.Expires = time.Now().Add(-time.Hour).Unix()
				return signer.mint(t, c)
			},
		},
		{
			name: "issued in the future",
			token: func() string {
				c := valid()
				c.IssuedAt = time.Now().Add(time.Hour).Unix()
				return signer.mint(t, c)
			},
		},
		{
			name: "empty subject",
			token: func() string {
				c := valid()
				c.Sub = ""
				return signer.mint(t, c)
			},
		},
		{
			// Correctly formed, correctly claimed, signed by a key whose
			// certificate the endpoint does not serve.
			name: "signed by an unknown key",
			token: func() string {
				return other.mint(t, valid())
			},
		},
		{
			name:  "not a jwt at all",
			token: func() string { return "not-a-token" },
		},
		{
			name:  "empty",
			token: func() string { return "" },
		},
		{
			// The dev verifier's format must not survive into production.
			name:  "dev verifier token",
			token: func() string { return "dev:firebase-uid-abc" },
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := v.Verify(ctx, tt.token())
			if !errors.Is(err, core.ErrInvalidToken) {
				t.Fatalf("Verify() error = %v, want core.ErrInvalidToken", err)
			}
		})
	}
}

func TestNewFirebaseVerifierRequiresAProjectID(t *testing.T) {
	if _, err := NewFirebaseVerifier(context.Background(), "", nil); err == nil {
		t.Fatal("NewFirebaseVerifier(\"\") returned no error; an empty project id disables the audience check")
	}
}

// The default must be the strict verifier. An unset APP_ENV landing on the
// dev verifier would authenticate anyone in any environment that forgot to
// set it -- which is exactly the environment most likely to forget.
func TestNewVerifierSelection(t *testing.T) {
	tests := []struct {
		name      string
		appEnv    string
		projectID string
		want      string // type name, or "" when construction must fail
	}{
		{name: "dev", appEnv: "dev", want: "transport.devVerifier"},
		{name: "staging with a project", appEnv: "staging", projectID: testProjectID, want: "transport.firebaseVerifier"},
		{name: "production with a project", appEnv: "production", projectID: testProjectID, want: "transport.firebaseVerifier"},
		{name: "production without a project", appEnv: "production", want: ""},
		{name: "unset APP_ENV without a project", appEnv: "", want: ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Setenv(EnvAppEnv, tt.appEnv)
			t.Setenv(EnvFirebaseProjectID, tt.projectID)

			got, err := NewVerifier(context.Background())
			if tt.want == "" {
				if err == nil {
					t.Fatalf("NewVerifier() built %T; want an error", got)
				}
				return
			}
			if err != nil {
				t.Fatalf("NewVerifier(): %v", err)
			}
			if name := fmt.Sprintf("%T", got); name != tt.want {
				t.Errorf("NewVerifier() = %s, want %s", name, tt.want)
			}
		})
	}
}

// ─────────────────────────── test signer ───────────────────────────

// testSigner mints tokens the way Google's token service does, and serves
// the matching certificate the way Google's certificate endpoint does.
type testSigner struct {
	kid     string
	key     *rsa.PrivateKey
	certPEM string
}

func newTestSigner(t *testing.T) *testSigner {
	t.Helper()
	return newTestSignerWithKID(t, testKeyID)
}

// newTestSignerWithKID mints under a distinct key id. Google changes the kid
// when it rotates, so a rotation test that reused one would be modelling
// something that never happens.
func newTestSignerWithKID(t *testing.T, kid string) *testSigner {
	t.Helper()

	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}

	tmpl := &x509.Certificate{
		SerialNumber: big.NewInt(1),
		Subject:      pkix.Name{CommonName: "securetoken.google.com"},
		NotBefore:    time.Now().Add(-time.Hour),
		NotAfter:     time.Now().Add(24 * time.Hour),
	}
	der, err := x509.CreateCertificate(rand.Reader, tmpl, tmpl, &key.PublicKey, key)
	if err != nil {
		t.Fatalf("create certificate: %v", err)
	}

	return &testSigner{
		kid:     kid,
		key:     key,
		certPEM: string(pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: der})),
	}
}

// claims is the subset of a Firebase ID token this API depends on.
type claims struct {
	Iss      string `json:"iss"`
	Aud      string `json:"aud"`
	Sub      string `json:"sub"`
	IssuedAt int64  `json:"iat"`
	Expires  int64  `json:"exp"`
	AuthTime int64  `json:"auth_time"`
}

func (s *testSigner) mint(t *testing.T, c claims) string {
	t.Helper()

	header := map[string]string{"alg": "RS256", "kid": s.kid, "typ": "JWT"}
	signingInput := encodeSegment(t, header) + "." + encodeSegment(t, c)
	digest := sha256.Sum256([]byte(signingInput))
	sig, err := rsa.SignPKCS1v15(rand.Reader, s.key, crypto.SHA256, digest[:])
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	return signingInput + "." + base64.RawURLEncoding.EncodeToString(sig)
}

func encodeSegment(t *testing.T, v any) string {
	t.Helper()
	raw, err := json.Marshal(v)
	if err != nil {
		t.Fatalf("marshal segment: %v", err)
	}
	return base64.RawURLEncoding.EncodeToString(raw)
}

// certTransport answers the certificate endpoint and refuses everything
// else, so a test that accidentally reaches the real internet fails rather
// than passing for the wrong reason. It counts fetches, which is how the
// caching tests observe the cache.
type certTransport struct {
	kid       string
	certPEM   string
	cacheCtrl string
	fail      bool // simulate an outage at the certificate endpoint

	mu      sync.Mutex
	fetches int
}

func (c *certTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	if req.URL.String() != certURL {
		return nil, errors.New("unexpected request in test: " + req.URL.String())
	}
	c.mu.Lock()
	c.fetches++
	failing := c.fail
	c.mu.Unlock()

	if failing {
		return nil, errors.New("certificate endpoint is down")
	}

	body, err := json.Marshal(map[string]string{c.kid: c.certPEM})
	if err != nil {
		return nil, err
	}
	header := http.Header{"Content-Type": []string{"application/json"}}
	if c.cacheCtrl != "" {
		header.Set("Cache-Control", c.cacheCtrl)
	}
	return &http.Response{
		StatusCode: http.StatusOK,
		Body:       io.NopCloser(strings.NewReader(string(body))),
		Header:     header,
		Request:    req,
	}, nil
}

func (c *certTransport) count() int {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.fetches
}

func newTestVerifier(t *testing.T, ctx context.Context, projectID string, s *testSigner) TokenVerifier {
	t.Helper()
	v, _ := newTestVerifierWithSpy(t, ctx, projectID, s)
	return v
}

func newTestVerifierWithSpy(t *testing.T, _ context.Context, projectID string, s *testSigner) (TokenVerifier, *certTransport) {
	t.Helper()
	spy := &certTransport{kid: s.kid, certPEM: s.certPEM, cacheCtrl: "public, max-age=3600"}
	v, err := NewFirebaseVerifier(context.Background(), projectID, &http.Client{Transport: spy})
	if err != nil {
		t.Fatalf("NewFirebaseVerifier(): %v", err)
	}
	return v, spy
}

// ─────────────────────────── certificate cache ───────────────────────────

// A verifier that refetched Google's certificates on every call would add a
// network round trip to every authenticated request in the product.
func TestCertificatesAreCached(t *testing.T) {
	ctx := context.Background()
	signer := newTestSigner(t)
	v, spy := newTestVerifierWithSpy(t, ctx, testProjectID, signer)
	token := signer.mint(t, validClaims())

	for i := 0; i < 3; i++ {
		if _, err := v.Verify(ctx, token); err != nil {
			t.Fatalf("Verify() call %d: %v", i+1, err)
		}
	}
	if got := spy.count(); got != 1 {
		t.Errorf("certificate fetches = %d, want 1", got)
	}
}

// Google rotates signing keys, and a token signed with the new key arrives
// before any max-age would tell us to refresh. An unknown kid has to force a
// refetch or every session breaks until the cache happens to expire.
func TestUnknownKidForcesARefetch(t *testing.T) {
	ctx := context.Background()
	old := newTestSigner(t)
	rotated := newTestSignerWithKID(t, "test-key-2")

	spy := &certTransport{kid: old.kid, certPEM: old.certPEM, cacheCtrl: "public, max-age=3600"}
	clock := &fakeClock{now: time.Now()}
	v := newClockedVerifier(spy, clock)

	// Warm the cache on the old key.
	if _, err := v.Verify(ctx, old.mint(t, validClaims())); err != nil {
		t.Fatalf("Verify() with the original key: %v", err)
	}

	// Google rotates. The cache is still well inside max-age.
	spy.kid, spy.certPEM = rotated.kid, rotated.certPEM
	clock.advance(2 * minRefetchInterval)

	if _, err := v.Verify(ctx, rotated.mint(t, validClaims())); err != nil {
		t.Fatalf("Verify() after key rotation: %v", err)
	}
	if got := spy.count(); got != 2 {
		t.Errorf("certificate fetches = %d, want 2 (one warm-up, one rotation)", got)
	}
}

// A stream of forged tokens carrying random kids must not become a stream of
// outbound requests to Google.
func TestUnknownKidRefetchIsRateLimited(t *testing.T) {
	ctx := context.Background()
	signer := newTestSigner(t)
	forger := newTestSignerWithKID(t, "forged-kid")

	spy := &certTransport{kid: signer.kid, certPEM: signer.certPEM, cacheCtrl: "public, max-age=3600"}
	clock := &fakeClock{now: time.Now()}
	v := newClockedVerifier(spy, clock)

	if _, err := v.Verify(ctx, signer.mint(t, validClaims())); err != nil {
		t.Fatalf("Verify() warm-up: %v", err)
	}

	// Ten forged tokens inside ONE refetch window. The clock moves past the
	// interval once, so the first unknown kid may trigger a single refetch
	// and the nine behind it must not.
	clock.advance(2 * minRefetchInterval)
	for i := 0; i < 10; i++ {
		if _, err := v.Verify(ctx, forger.mint(t, validClaims())); !errors.Is(err, core.ErrInvalidToken) {
			t.Fatalf("forged token %d: error = %v, want core.ErrInvalidToken", i, err)
		}
	}
	if got := spy.count(); got != 2 {
		t.Errorf("certificate fetches = %d, want 2 (warm-up plus one rate-limited retry)", got)
	}
}

// An outage at Google's certificate endpoint must not become an outage here
// while the keys we already hold still verify tokens.
func TestStaleKeysSurviveAFetchFailure(t *testing.T) {
	ctx := context.Background()
	signer := newTestSigner(t)

	spy := &certTransport{kid: signer.kid, certPEM: signer.certPEM, cacheCtrl: "public, max-age=60"}
	clock := &fakeClock{now: time.Now()}
	v := newClockedVerifier(spy, clock)

	if _, err := v.Verify(ctx, signer.mint(t, validClaims())); err != nil {
		t.Fatalf("Verify() warm-up: %v", err)
	}

	spy.fail = true
	clock.advance(2 * time.Hour) // well past max-age

	if _, err := v.Verify(ctx, signer.mint(t, validClaims())); err != nil {
		t.Fatalf("Verify() during a certificate-endpoint outage: %v", err)
	}
}

func TestMaxAge(t *testing.T) {
	tests := []struct {
		header string
		want   time.Duration
	}{
		{"public, max-age=19621, must-revalidate, no-transform", 19621 * time.Second},
		{"max-age=300", 300 * time.Second},
		{"", defaultCertTTL},
		{"no-cache", defaultCertTTL},
		{"max-age=notanumber", defaultCertTTL},
		{"max-age=0", defaultCertTTL},
	}
	for _, tt := range tests {
		if got := maxAge(tt.header); got != tt.want {
			t.Errorf("maxAge(%q) = %v, want %v", tt.header, got, tt.want)
		}
	}
}

// ─────────────────────────── helpers ───────────────────────────

func validClaims() claims {
	return claims{
		Iss:      "https://securetoken.google.com/" + testProjectID,
		Aud:      testProjectID,
		Sub:      "firebase-uid-abc",
		IssuedAt: time.Now().Add(-time.Minute).Unix(),
		Expires:  time.Now().Add(time.Hour).Unix(),
		AuthTime: time.Now().Add(-time.Minute).Unix(),
	}
}

// fakeClock drives the cache's expiry without a sleep.
type fakeClock struct {
	mu  sync.Mutex
	now time.Time
}

func (c *fakeClock) Now() time.Time {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.now
}

func (c *fakeClock) advance(d time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.now = c.now.Add(d)
}

// newClockedVerifier builds a verifier whose cache ages on the fake clock
// while its claim checks stay on the real one, so a test can expire
// certificates without also expiring its own tokens.
func newClockedVerifier(spy *certTransport, clock *fakeClock) firebaseVerifier {
	return firebaseVerifier{
		projectID: testProjectID,
		certs: &certCache{
			client: &http.Client{Transport: spy},
			url:    certURL,
			now:    clock.Now,
		},
		now: time.Now,
	}
}
