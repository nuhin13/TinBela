package invites

import (
	"strings"
	"testing"
)

func TestNewTokenIsUnpredictable(t *testing.T) {
	seen := make(map[string]bool, 1000)
	for i := 0; i < 1000; i++ {
		tok, err := NewToken()
		if err != nil {
			t.Fatalf("NewToken: %v", err)
		}
		if seen[tok] {
			t.Fatalf("duplicate token after %d draws", i)
		}
		seen[tok] = true
		// 32 bytes base64-url without padding.
		if len(tok) < 40 {
			t.Fatalf("token %q is %d chars, too short to be 32 bytes", tok, len(tok))
		}
		if strings.ContainsAny(tok, "+/=") {
			t.Fatalf("token %q is not URL-safe", tok)
		}
	}
}

func TestTokenLengthFloorIsEnforced(t *testing.T) {
	t.Setenv("INVITE_TOKEN_BYTES", "8")
	if _, err := NewToken(); err == nil {
		t.Fatal("accepted an 8-byte token; the floor is not enforced")
	}

	t.Setenv("INVITE_TOKEN_BYTES", "not-a-number")
	if _, err := NewToken(); err == nil {
		t.Fatal("accepted a non-numeric INVITE_TOKEN_BYTES")
	}
}
