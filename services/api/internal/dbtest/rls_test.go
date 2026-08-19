// Package dbtest proves the database enforces what the application assumes.
//
// These tests live outside internal/db on purpose: that directory is
// sqlc-generated and hand-written files there are blocked by
// .claude/hooks/pre-edit-guard.sh.
package dbtest

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
)

const (
	tenantA   = "aaaaaaaa-0000-0000-0000-000000000001"
	tenantB   = "bbbbbbbb-0000-0000-0000-000000000002"
	probeUser = "cccccccc-0000-0000-0000-0000000000ff"
)

// TestRLSTenantIsolation is half of Epic 01's gate: a cross-tenant read
// returns zero rows.
func TestRLSTenantIsolation(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	owner, appDSN := newTestDatabase(ctx, t, "tinbela_rls_test")
	seedTwoTenants(ctx, t, owner)

	app, err := connectSimple(ctx, appDSN)
	if err != nil {
		t.Fatalf("connect as %s: %v", appUser, err)
	}
	defer app.Close(ctx)

	// The role the API actually uses must not be able to sidestep RLS.
	// Without this the rest of the test would pass against a superuser only
	// because the fixture happens to be scoped correctly.
	var super, bypass bool
	if err := app.QueryRow(ctx,
		`SELECT rolsuper, rolbypassrls FROM pg_roles WHERE rolname = current_user`,
	).Scan(&super, &bypass); err != nil {
		t.Fatalf("role attributes: %v", err)
	}
	if super || bypass {
		t.Fatalf("%s has rolsuper=%v rolbypassrls=%v; RLS cannot apply to it",
			appUser, super, bypass)
	}

	t.Run("unscoped session reads nothing", func(t *testing.T) {
		for _, table := range []string{"tenants", "memberships", "ledger_entries"} {
			if got := count(ctx, t, app, table); got != 0 {
				t.Errorf("%s: unscoped session saw %d rows, want 0", table, got)
			}
		}
	})

	t.Run("each tenant sees only its own rows", func(t *testing.T) {
		for _, tc := range []struct{ name, tenant, other string }{
			{"A", tenantA, tenantB},
			{"B", tenantB, tenantA},
		} {
			scope(ctx, t, app, tc.tenant)
			if got := count(ctx, t, app, "ledger_entries"); got != 1 {
				t.Errorf("tenant %s: saw %d of its own ledger rows, want 1", tc.name, got)
			}
			var leaked int
			if err := app.QueryRow(ctx,
				`SELECT count(*) FROM ledger_entries WHERE tenant_id = $1`, tc.other,
			).Scan(&leaked); err != nil {
				t.Fatalf("cross-tenant read: %v", err)
			}
			if leaked != 0 {
				t.Errorf("tenant %s read %d rows belonging to the other tenant, want 0",
					tc.name, leaked)
			}
		}
	})

	t.Run("cannot write into another tenant", func(t *testing.T) {
		scope(ctx, t, app, tenantA)
		_, err := app.Exec(ctx, fmt.Sprintf(`
			INSERT INTO ledger_entries
				(id, tenant_id, kind, amount_paisa, occurred_on, entered_by)
			VALUES (gen_random_uuid(), '%s', 'FOOD_COST', 100, DATE '2026-01-01', '%s')`,
			tenantB, probeUser))
		if err == nil {
			t.Error("tenant A inserted a row owned by tenant B; WITH CHECK is not enforcing")
		}
	})
}

func seedTwoTenants(ctx context.Context, t *testing.T, conn *pgx.Conn) {
	t.Helper()
	stmts := []string{
		fmt.Sprintf(`INSERT INTO users (id, name) VALUES ('%s', 'rls probe')`, probeUser),
	}
	for i, tenant := range []string{tenantA, tenantB} {
		stmts = append(stmts,
			fmt.Sprintf(`INSERT INTO tenants (id, name, kind)
				VALUES ('%s', 'mess %d', 'MESS')`, tenant, i),
			fmt.Sprintf(`INSERT INTO memberships
				(id, tenant_id, user_id, role, display_name, joined_at)
				VALUES (gen_random_uuid(), '%s', '%s', 'MEMBER', 'm%d', DATE '2026-01-01')`,
				tenant, probeUser, i),
			fmt.Sprintf(`INSERT INTO ledger_entries
				(id, tenant_id, kind, amount_paisa, occurred_on, entered_by)
				VALUES (gen_random_uuid(), '%s', 'FOOD_COST', %d, DATE '2026-01-01', '%s')`,
				tenant, 1000*(i+1), probeUser),
		)
	}
	for _, s := range stmts {
		if _, err := conn.Exec(ctx, s); err != nil {
			t.Fatalf("seed: %v", err)
		}
	}
}

func scope(ctx context.Context, t *testing.T, conn *pgx.Conn, tenant string) {
	t.Helper()
	if _, err := conn.Exec(ctx, fmt.Sprintf("SET app.tenant_id = '%s'", tenant)); err != nil {
		t.Fatalf("set app.tenant_id: %v", err)
	}
}

func count(ctx context.Context, t *testing.T, conn *pgx.Conn, table string) int {
	t.Helper()
	var n int
	if err := conn.QueryRow(ctx, "SELECT count(*) FROM "+table).Scan(&n); err != nil {
		t.Fatalf("count %s: %v", table, err)
	}
	return n
}
