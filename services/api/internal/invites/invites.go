// Package invites mints the tokens that turn "a name the manager typed"
// into "a person with an account".
//
// A token is the only credential on the member link, so it has to stand on
// its own entropy: there is no password behind it and, in v1.0, no expiry
// (ADR-0009). Entropy, revocation and the no-expiry decision are task 04.5
// and marked ★ -- what is here is the mechanism, not the policy sign-off.
package invites

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"os"
	"strconv"
)

// DefaultBytes is the token length when INVITE_TOKEN_BYTES is unset. 32
// bytes is 256 bits: at a billion guesses a second, brute force takes
// longer than the universe has existed. The link is the credential, so this
// is not a place to economise.
const DefaultBytes = 32

// MinBytes is the floor. Below this the token stops being a credential.
const MinBytes = 16

// NewToken returns a URL-safe token from crypto/rand.
//
// It returns an error rather than falling back to a weaker source: a
// silently weak invite token is indistinguishable from a strong one until
// someone walks into a mess they were never invited to.
func NewToken() (string, error) {
	n, err := tokenBytes()
	if err != nil {
		return "", err
	}
	buf := make([]byte, n)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("invite token: %w", err)
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

func tokenBytes() (int, error) {
	raw := os.Getenv("INVITE_TOKEN_BYTES")
	if raw == "" {
		return DefaultBytes, nil
	}
	n, err := strconv.Atoi(raw)
	if err != nil {
		return 0, fmt.Errorf("INVITE_TOKEN_BYTES=%q is not a number", raw)
	}
	if n < MinBytes {
		return 0, fmt.Errorf("INVITE_TOKEN_BYTES=%d is below the %d-byte floor", n, MinBytes)
	}
	return n, nil
}

// Link builds the URL a member opens. Base comes from INVITE_BASE_URL so
// the same binary serves dev, staging and production without a rebuild.
func Link(token string) string {
	base := os.Getenv("INVITE_BASE_URL")
	if base == "" {
		base = "https://tinbela.app/j"
	}
	return base + "/" + token
}
