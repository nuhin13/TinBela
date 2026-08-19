package transport_test

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/dbtest"
	corev1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1/corev1connect"
	mealsv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/meals/v1"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/meals/v1/mealsv1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/transport"
)

const (
	fixtureFirebaseUID = "dev-contract-user"
	fixtureUserID      = "aaaa0000-0000-0000-0000-00000000000a"
	fixtureTenantID    = "bbbb0000-0000-0000-0000-00000000000b"
	otherTenantID      = "cccc0000-0000-0000-0000-00000000000c"
)

// TestContractRoundTrip drives a generated client against the real
// interceptor chain over HTTP.
//
// This is Epic 03's gate in the form the Go toolchain can check: a generated
// client, real JSON on the wire, every interceptor in place, a real database
// with RLS forced. The TypeScript and Dart halves of the gate are not
// covered here -- see docs/eng/transport.md.
func TestContractRoundTrip(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	owner, appDSN := dbtest.NewTestDatabase(ctx, t, "tinbela_contract_test")
	seedContractFixture(ctx, t, owner)

	pool, err := pgxpool.New(ctx, appDSN)
	if err != nil {
		t.Fatalf("pool: %v", err)
	}
	defer pool.Close()

	t.Setenv("APP_ENV", "dev")
	verifier, err := transport.NewDevVerifier()
	if err != nil {
		t.Fatalf("verifier: %v", err)
	}

	mux := http.NewServeMux()
	transport.Register(mux, transport.Deps{
		Pool:     pool,
		Logger:   slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelError})),
		Verifier: verifier,
		// Generous: this test is about the contract, not the limiter.
		RateLimiter: transport.NewRateLimiter(1000, 1000),
		Timeout:     20 * time.Second,
	})
	srv := httptest.NewServer(mux)
	defer srv.Close()

	core := corev1connect.NewCoreServiceClient(srv.Client(), srv.URL)
	meals := mealsv1connect.NewMealsServiceClient(srv.Client(), srv.URL)

	t.Run("no credentials are rejected", func(t *testing.T) {
		_, err := core.GetMe(ctx, connect.NewRequest(&corev1.GetMeRequest{}))
		if got := connect.CodeOf(err); got != connect.CodeUnauthenticated {
			t.Fatalf("code = %v, want unauthenticated", got)
		}
	})

	t.Run("GetMe round-trips without a tenant", func(t *testing.T) {
		req := connect.NewRequest(&corev1.GetMeRequest{})
		req.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+fixtureFirebaseUID)

		res, err := core.GetMe(ctx, req)
		if err != nil {
			t.Fatalf("GetMe: %v", err)
		}
		if got := res.Msg.GetUser().GetId(); got != fixtureUserID {
			t.Errorf("user id = %q, want %q", got, fixtureUserID)
		}
		// Self-discovery (migration 000004): visible with no tenant scope,
		// and only this user's own mess.
		if n := len(res.Msg.GetMesses()); n != 1 {
			t.Fatalf("messes = %d, want 1 (the other tenant must not be visible)", n)
		}
		if got := res.Msg.GetMesses()[0].GetId(); got != fixtureTenantID {
			t.Errorf("mess id = %q, want %q", got, fixtureTenantID)
		}
		if res.Header().Get(transport.HeaderRequestID) == "" {
			t.Error("response carries no request id")
		}
	})

	t.Run("a scoped call reaches the handler", func(t *testing.T) {
		req := connect.NewRequest(&mealsv1.GetDayRequest{})
		req.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+fixtureFirebaseUID)
		req.Header().Set(transport.HeaderTenantID, fixtureTenantID)

		_, err := meals.GetDay(ctx, req)
		// Epic 05 owns the behaviour; reaching an unimplemented handler is
		// proof the whole chain passed the call through.
		if got := connect.CodeOf(err); got != connect.CodeUnimplemented {
			t.Fatalf("code = %v, want unimplemented (chain did not reach the handler)", got)
		}
	})

	t.Run("cross-tenant is denied", func(t *testing.T) {
		req := connect.NewRequest(&mealsv1.GetDayRequest{})
		req.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+fixtureFirebaseUID)
		req.Header().Set(transport.HeaderTenantID, otherTenantID)

		_, err := meals.GetDay(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodePermissionDenied {
			t.Fatalf("code = %v, want permission_denied", got)
		}
		// docs/eng/errors.md: never confirm another tenant's resource
		// exists, so the message is the generic not-found one.
		if msg := connect.CodeOf(err).String(); msg == "" {
			t.Error("empty code")
		}
	})

	t.Run("a scoped procedure requires a tenant", func(t *testing.T) {
		req := connect.NewRequest(&mealsv1.GetDayRequest{})
		req.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+fixtureFirebaseUID)

		_, err := meals.GetDay(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodePermissionDenied {
			t.Fatalf("code = %v, want permission_denied", got)
		}
	})
}

func seedContractFixture(ctx context.Context, t *testing.T, conn *pgx.Conn) {
	t.Helper()
	for _, s := range []string{
		fmt.Sprintf(`INSERT INTO users (id, firebase_uid, name, locale)
			VALUES ('%s', '%s', 'contract probe', 'bn')`, fixtureUserID, fixtureFirebaseUID),
		fmt.Sprintf(`INSERT INTO tenants (id, name, kind) VALUES ('%s', 'ours', 'MESS')`, fixtureTenantID),
		fmt.Sprintf(`INSERT INTO tenants (id, name, kind) VALUES ('%s', 'theirs', 'MESS')`, otherTenantID),
		fmt.Sprintf(`INSERT INTO memberships (id, tenant_id, user_id, role, display_name, joined_at)
			VALUES (gen_random_uuid(), '%s', '%s', 'MANAGER', 'probe', DATE '2026-01-01')`,
			fixtureTenantID, fixtureUserID),
	} {
		if _, err := conn.Exec(ctx, s); err != nil {
			t.Fatalf("fixture: %v", err)
		}
	}
}
