// Package db holds the sqlc-generated queries (Epic 01 task 01.9) and the
// tests that prove the database enforces what the application assumes.
package db

import (
	"context"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
)

const (
	ownerDSNDefault = "postgres://tinbela:tinbela@localhost:5432/tinbela?sslmode=disable"
	appUser         = "tinbela_app"
	appPassword     = "tinbela_app" // dev only; see migration 000003
	testDBName      = "tinbela_rls_test"

	tenantA = "aaaaaaaa-0000-0000-0000-000000000001"
	tenantB = "bbbbbbbb-0000-0000-0000-000000000002"
)

// dsnFor rewrites the owner DSN to point at another database, optionally as
// another role.
func dsnFor(t *testing.T, base, dbName, user, pass string) string {
	t.Helper()
	u, err := url.Parse(base)
	if err != nil {
		t.Fatalf("parse PG_DSN: %v", err)
	}
	if user != "" {
		u.User = url.UserPassword(user, pass)
	}
	u.Path = "/" + dbName
	return u.String()
}

// connectSimple uses the simple protocol so multi-statement migration files
// can be executed in one round trip.
func connectSimple(ctx context.Context, dsn string) (*pgx.Conn, error) {
	cfg, err := pgx.ParseConfig(dsn)
	if err != nil {
		return nil, err
	}
	cfg.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol
	return pgx.ConnectConfig(ctx, cfg)
}

// TestRLSTenantIsolation is Epic 01's gate: a cross-tenant read returns zero
// rows.
//
// It runs against a database it creates and drops itself, because the demo
// database cannot be cleaned up: the append-only DO INSTEAD NOTHING rules
// break ON DELETE CASCADE, so a tenant carrying ledger rows can never be
// removed.
func TestRLSTenantIsolation(t *testing.T) {
	ownerDSN := os.Getenv("PG_DSN")
	if ownerDSN == "" {
		ownerDSN = ownerDSNDefault
	}

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	adminDSN := dsnFor(t, ownerDSN, "postgres", "", "")
	admin, err := connectSimple(ctx, adminDSN)
	if err != nil {
		t.Skipf("postgres unavailable, skipping: %v", err)
	}
	defer admin.Close(ctx)

	if _, err := admin.Exec(ctx, "DROP DATABASE IF EXISTS "+testDBName); err != nil {
		t.Fatalf("drop test db: %v", err)
	}
	if _, err := admin.Exec(ctx, "CREATE DATABASE "+testDBName); err != nil {
		t.Fatalf("create test db: %v", err)
	}
	defer func() {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		if _, err := admin.Exec(ctx, "DROP DATABASE IF EXISTS "+testDBName); err != nil {
			t.Logf("cleanup: dropping %s: %v", testDBName, err)
		}
	}()

	ownerTestDSN := dsnFor(t, ownerDSN, testDBName, "", "")
	owner, err := connectSimple(ctx, ownerTestDSN)
	if err != nil {
		t.Fatalf("connect as owner: %v", err)
	}
	applyMigrations(ctx, t, owner)
	seedTwoTenants(ctx, t, owner)
	owner.Close(ctx)

	appDSN := dsnFor(t, ownerDSN, testDBName, appUser, appPassword)
	app, err := connectSimple(ctx, appDSN)
	if err != nil {
		t.Fatalf("connect as %s: %v", appUser, err)
	}
	defer app.Close(ctx)

	// The role the API actually uses must not be able to sidestep RLS.
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
			VALUES (gen_random_uuid(), '%s', 'FOOD_COST', 100, DATE '2026-01-01',
				'cccccccc-0000-0000-0000-0000000000ff')`, tenantB))
		if err == nil {
			t.Error("tenant A inserted a row owned by tenant B; WITH CHECK is not enforcing")
		}
	})
}

func applyMigrations(ctx context.Context, t *testing.T, conn *pgx.Conn) {
	t.Helper()
	entries, err := filepath.Glob(filepath.Join("..", "..", "migrations", "*.up.sql"))
	if err != nil || len(entries) == 0 {
		t.Fatalf("no migrations found: %v", err)
	}
	sort.Strings(entries)
	for _, f := range entries {
		sqlBytes, err := os.ReadFile(f)
		if err != nil {
			t.Fatalf("read %s: %v", f, err)
		}
		if _, err := conn.Exec(ctx, string(sqlBytes)); err != nil {
			t.Fatalf("apply %s: %v", filepath.Base(f), err)
		}
	}
}

func seedTwoTenants(ctx context.Context, t *testing.T, conn *pgx.Conn) {
	t.Helper()
	const userID = "cccccccc-0000-0000-0000-0000000000ff"
	stmts := []string{
		fmt.Sprintf(`INSERT INTO users (id, name) VALUES ('%s', 'rls probe')`, userID),
	}
	for i, tenant := range []string{tenantA, tenantB} {
		stmts = append(stmts,
			fmt.Sprintf(`INSERT INTO tenants (id, name, kind)
				VALUES ('%s', 'mess %d', 'MESS')`, tenant, i),
			fmt.Sprintf(`INSERT INTO memberships
				(id, tenant_id, user_id, role, display_name, joined_at)
				VALUES (gen_random_uuid(), '%s', '%s', 'MEMBER', 'm%d', DATE '2026-01-01')`,
				tenant, userID, i),
			fmt.Sprintf(`INSERT INTO ledger_entries
				(id, tenant_id, kind, amount_paisa, occurred_on, entered_by)
				VALUES (gen_random_uuid(), '%s', 'FOOD_COST', %d, DATE '2026-01-01', '%s')`,
				tenant, 1000*(i+1), userID),
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
