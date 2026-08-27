package transport_test

import (
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/dbtest"
	adminv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/admin/v1"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/admin/v1/adminv1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/transport"
)

// TestAdminService is Epic 16's backend: staff-only, cross-tenant, read-only
// (ADR-0016), audited. It seeds two messes and drives the real AdminService
// through its generated client.
func TestAdminService(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	const staffUID = "dev-staff"
	admin, adminPool, owner, cleanup := newAdminAPI(ctx, t, "tinbela_admin_test", staffUID)
	defer cleanup()

	// Two messes, each with an active member. Seeded as the owner (bypasses
	// RLS), which is how a cross-tenant fixture gets built at all.
	t1 := seedTenant(ctx, t, owner, "নীলক্ষেত মেস")
	t2 := seedTenant(ctx, t, owner, "মিরপুর মেস")
	seedUser(ctx, t, owner, "aaaa0000-0000-0000-0000-0000000016a1", "dev-m1", "রফিক")
	seedMembership(ctx, t, owner, t1, "aaaa0000-0000-0000-0000-0000000016a1")
	seedUser(ctx, t, owner, "aaaa0000-0000-0000-0000-0000000016a2", "dev-m2", "করিম")
	seedMembership(ctx, t, owner, t2, "aaaa0000-0000-0000-0000-0000000016a2")

	staff := func(r interface{ Header() http.Header }) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+staffUID)
	}

	t.Run("a non-staff caller is refused — 16.1", func(t *testing.T) {
		// A perfectly valid manager token must not reach the admin surface.
		req := connect.NewRequest(&adminv1.ListTenantsRequest{})
		req.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-m1")
		_, err := admin.ListTenants(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodePermissionDenied {
			t.Fatalf("code = %v, want permission_denied", got)
		}
	})

	t.Run("staff lists tenants across messes — 16.3", func(t *testing.T) {
		req := connect.NewRequest(&adminv1.ListTenantsRequest{PageSize: 10})
		staff(req)
		res, err := admin.ListTenants(ctx, req)
		if err != nil {
			t.Fatalf("ListTenants: %v", err)
		}
		if res.Msg.GetTotal() != 2 {
			t.Errorf("total = %d, want 2", res.Msg.GetTotal())
		}
		names := map[string]int32{}
		for _, tn := range res.Msg.GetTenants() {
			names[tn.GetName()] = tn.GetMemberCount()
		}
		if names["নীলক্ষেত মেস"] != 1 || names["মিরপুর মেস"] != 1 {
			t.Errorf("member counts wrong: %+v", names)
		}
	})

	t.Run("tenant search filters by name — 16.3", func(t *testing.T) {
		req := connect.NewRequest(&adminv1.ListTenantsRequest{Query: "মিরপুর", PageSize: 10})
		staff(req)
		res, err := admin.ListTenants(ctx, req)
		if err != nil {
			t.Fatalf("ListTenants: %v", err)
		}
		if len(res.Msg.GetTenants()) != 1 || res.Msg.GetTenants()[0].GetName() != "মিরপুর মেস" {
			t.Errorf("search returned %+v", res.Msg.GetTenants())
		}
	})

	t.Run("metrics count the fleet — 16.2", func(t *testing.T) {
		req := connect.NewRequest(&adminv1.GetMetricsRequest{})
		staff(req)
		res, err := admin.GetMetrics(ctx, req)
		if err != nil {
			t.Fatalf("GetMetrics: %v", err)
		}
		if res.Msg.GetActiveMesses() != 2 {
			t.Errorf("active_messes = %d, want 2", res.Msg.GetActiveMesses())
		}
	})

	t.Run("user lookup by firebase uid — 16.5", func(t *testing.T) {
		req := connect.NewRequest(&adminv1.FindUserRequest{FirebaseUid: "dev-m1"})
		staff(req)
		res, err := admin.FindUser(ctx, req)
		if err != nil {
			t.Fatalf("FindUser: %v", err)
		}
		if !strings.Contains(res.Msg.GetUserJson(), "রফিক") {
			t.Errorf("user_json = %q, want it to name রফিক", res.Msg.GetUserJson())
		}
	})

	t.Run("a missing user is an empty answer, not an error — 16.5", func(t *testing.T) {
		req := connect.NewRequest(&adminv1.FindUserRequest{PhoneE164: "+8809999999999"})
		staff(req)
		res, err := admin.FindUser(ctx, req)
		if err != nil {
			t.Fatalf("FindUser: %v", err)
		}
		if res.Msg.GetUserJson() != "" {
			t.Errorf("user_json = %q, want empty", res.Msg.GetUserJson())
		}
	})

	t.Run("feature flags round-trip — 16.6", func(t *testing.T) {
		set := connect.NewRequest(&adminv1.SetFlagRequest{Key: "ads_enabled", Value: true})
		staff(set)
		if _, err := admin.SetFlag(ctx, set); err != nil {
			t.Fatalf("SetFlag: %v", err)
		}
		get := connect.NewRequest(&adminv1.GetFlagsRequest{})
		staff(get)
		res, err := admin.GetFlags(ctx, get)
		if err != nil {
			t.Fatalf("GetFlags: %v", err)
		}
		if !res.Msg.GetFlags()["ads_enabled"] {
			t.Errorf("flags = %+v, want ads_enabled true", res.Msg.GetFlags())
		}
	})

	t.Run("the inspector is founder-owned — 16.4 star", func(t *testing.T) {
		req := connect.NewRequest(&adminv1.GetTenantRequest{TenantId: t1})
		staff(req)
		_, err := admin.GetTenant(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodeUnimplemented {
			t.Fatalf("code = %v, want unimplemented (16.4 is star)", got)
		}
	})

	t.Run("the admin role physically cannot mutate customer data — ADR-0016", func(t *testing.T) {
		// The read-only guarantee is a grant, not a promise: even a raw write
		// on the admin connection is refused by Postgres.
		_, err := adminPool.Exec(ctx,
			`INSERT INTO tenants (id, name, kind, billing_mode, timezone)
			 VALUES ($1, 'smuggled', 'MESS', 'RATE_BASED', 'Asia/Dhaka')`, uuid.New())
		if err == nil {
			t.Fatal("tinbela_admin inserted into a customer table; the role is not read-only")
		}
		if !strings.Contains(strings.ToLower(err.Error()), "permission denied") {
			t.Fatalf("want a permission-denied error, got: %v", err)
		}
	})

	t.Run("every read is audited — 16.8", func(t *testing.T) {
		var n int
		if err := owner.QueryRow(ctx,
			`SELECT count(*) FROM admin_audit_log WHERE staff_uid = $1`, staffUID).Scan(&n); err != nil {
			t.Fatalf("count audit: %v", err)
		}
		if n == 0 {
			t.Error("no audit rows were written for the staff reads")
		}
	})
}

func newAdminAPI(ctx context.Context, t *testing.T, dbName, staffUID string) (adminv1connect.AdminServiceClient, *pgxpool.Pool, *pgx.Conn, func()) {
	t.Helper()

	owner, appDSN := dbtest.NewTestDatabase(ctx, t, dbName)
	// The staff user must exist so the auth interceptor can resolve the token.
	seedUser(ctx, t, owner, "aaaa0000-0000-0000-0000-0000000016ff", staffUID, "স্টাফ")

	appPool, err := pgxpool.New(ctx, appDSN)
	if err != nil {
		t.Fatalf("app pool: %v", err)
	}
	adminPool, err := pgxpool.New(ctx,
		dbtest.DSNFor(t, dbtest.OwnerDSN(), dbName, "tinbela_admin", "tinbela_admin"))
	if err != nil {
		t.Fatalf("admin pool: %v", err)
	}

	t.Setenv("APP_ENV", "dev")
	verifier, err := transport.NewDevVerifier()
	if err != nil {
		t.Fatalf("verifier: %v", err)
	}

	mux := http.NewServeMux()
	transport.Register(mux, transport.Deps{
		Pool:        appPool,
		Logger:      slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelError})),
		Verifier:    verifier,
		RateLimiter: transport.NewRateLimiter(1000, 1000),
		Timeout:     30 * time.Second,
		AdminPool:   adminPool,
		Staff:       transport.NewStaffPolicy([]string{staffUID}),
		AdminIPs:    transport.NewIPAllowList(nil),
	})
	srv := httptest.NewServer(mux)

	return adminv1connect.NewAdminServiceClient(srv.Client(), srv.URL), adminPool, owner, func() {
		srv.Close()
		adminPool.Close()
		appPool.Close()
	}
}

func seedTenant(ctx context.Context, t *testing.T, conn *pgx.Conn, name string) string {
	t.Helper()
	id := uuid.NewString()
	if _, err := conn.Exec(ctx,
		`INSERT INTO tenants (id, name, kind, billing_mode, timezone)
		 VALUES ($1, $2, 'MESS', 'RATE_BASED', 'Asia/Dhaka')`, id, name); err != nil {
		t.Fatalf("seed tenant: %v", err)
	}
	return id
}

func seedMembership(ctx context.Context, t *testing.T, conn *pgx.Conn, tenantID, userID string) {
	t.Helper()
	if _, err := conn.Exec(ctx,
		`INSERT INTO memberships (id, tenant_id, user_id, role, display_name, joined_at)
		 VALUES ($1, $2, $3, 'MANAGER', 'ম্যানেজার', current_date)`,
		uuid.New(), tenantID, userID); err != nil {
		t.Fatalf("seed membership: %v", err)
	}
}
