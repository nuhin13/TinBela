package dbtest_test

// The regression test for the bug that made GetMe fail intermittently until
// the process was restarted (docs/eng/transport.md).
//
// It has to reuse ONE connection across TWO transactions. That is the entire
// point, and it is why nothing else in this suite caught the bug: every other
// test opens a fresh connection, which is exactly the condition under which
// the failure cannot occur. A pooled connection is what production has.

import (
	"context"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"

	"github.com/droidbuilder/tinbela/services/api/internal/dbtest"
)

// TestGUCResetDoesNotPoisonTheConnection proves that a connection which has
// served a tenant-scoped request can still serve a tenant-free one.
//
// SET LOCAL restores the SESSION value at commit, not "unset". For a custom
// GUC first introduced inside a transaction that value is '', and ''::uuid
// raises 22P02. Before migration 000006 the policies cast the setting
// directly, so the second transaction below failed.
func TestGUCResetDoesNotPoisonTheConnection(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	owner, appDSN := dbtest.NewTestDatabase(ctx, t, "tinbela_guc_reset_test")

	// ids are supplied by the application, not the schema -- tenants.id and
	// users.id are bare `uuid PRIMARY KEY` with no default.
	var tenantID, userID string
	if err := owner.QueryRow(ctx, `
		INSERT INTO tenants (id, name, kind)
		VALUES (gen_random_uuid(), 'গুক টেস্ট মেস', 'MESS')
		RETURNING id`).Scan(&tenantID); err != nil {
		t.Fatalf("seed tenant: %v", err)
	}
	if err := owner.QueryRow(ctx, `
		INSERT INTO users (id, firebase_uid, name, locale)
		VALUES (gen_random_uuid(), 'dev-guc', 'গুক', 'bn')
		RETURNING id`).Scan(&userID); err != nil {
		t.Fatalf("seed user: %v", err)
	}
	if _, err := owner.Exec(ctx, `
		INSERT INTO memberships (id, tenant_id, user_id, role, display_name, joined_at)
		VALUES (gen_random_uuid(), $1, $2, 'MANAGER', 'গুক', CURRENT_DATE)`,
		tenantID, userID); err != nil {
		t.Fatalf("seed membership: %v", err)
	}

	// As the application role, so RLS actually applies (migration 000003).
	conn, err := pgx.Connect(ctx, appDSN)
	if err != nil {
		t.Fatalf("connect as %s: %v", dbtest.AppUser, err)
	}
	defer func() { _ = conn.Close(context.WithoutCancel(ctx)) }()

	// ── transaction 1: a tenant-scoped request, exactly as the interceptors
	// issue it. This is what poisons the connection.
	tx1, err := conn.Begin(ctx)
	if err != nil {
		t.Fatalf("begin 1: %v", err)
	}
	if _, err := tx1.Exec(ctx,
		"SELECT set_config('app.user_id', $1, true)", userID); err != nil {
		t.Fatalf("set app.user_id: %v", err)
	}
	if _, err := tx1.Exec(ctx,
		"SELECT set_config('app.tenant_id', $1, true)", tenantID); err != nil {
		t.Fatalf("set app.tenant_id: %v", err)
	}
	var scoped int
	if err := tx1.QueryRow(ctx,
		`SELECT count(*) FROM memberships`).Scan(&scoped); err != nil {
		t.Fatalf("tenant-scoped read: %v", err)
	}
	if scoped != 1 {
		t.Fatalf("tenant-scoped read saw %d memberships, want 1", scoped)
	}
	if err := tx1.Commit(ctx); err != nil {
		t.Fatalf("commit 1: %v", err)
	}

	// The setting is now '' rather than unset. Assert that directly, so a
	// future Postgres release that changes this behaviour is visible here
	// rather than as a silent change in what this test is proving.
	var afterCommit *string
	if err := conn.QueryRow(ctx,
		`SELECT current_setting('app.tenant_id', true)`).Scan(&afterCommit); err != nil {
		t.Fatalf("read setting after commit: %v", err)
	}
	if afterCommit == nil {
		t.Log("note: app.tenant_id reverted to NULL, not '' -- the original " +
			"bug cannot occur on this Postgres version")
	} else if *afterCommit != "" {
		t.Fatalf("app.tenant_id after commit = %q, want \"\" or NULL", *afterCommit)
	}

	// ── transaction 2: a TENANT-FREE request on the SAME connection, which
	// is what GetMe is. Before 000006 this failed with 22P02.
	tx2, err := conn.Begin(ctx)
	if err != nil {
		t.Fatalf("begin 2: %v", err)
	}
	defer func() { _ = tx2.Rollback(context.WithoutCancel(ctx)) }()

	if _, err := tx2.Exec(ctx,
		"SELECT set_config('app.user_id', $1, true)", userID); err != nil {
		t.Fatalf("set app.user_id: %v", err)
	}

	var selfRows int
	if err := tx2.QueryRow(ctx,
		`SELECT count(*) FROM memberships`).Scan(&selfRows); err != nil {
		t.Fatalf("self-discovery read on a reused connection: %v\n"+
			"this is the GetMe bug: SET LOCAL reverted app.tenant_id to '' "+
			"and the policy cast it to uuid", err)
	}
	if selfRows != 1 {
		t.Errorf("self-discovery saw %d memberships, want 1", selfRows)
	}

	// tenants carries both a tenant_isolation and a user_self_discovery
	// policy, and Postgres ORs permissive policies -- so it evaluates the
	// tenant cast even on this tenant-free path.
	var tenantRows int
	if err := tx2.QueryRow(ctx,
		`SELECT count(*) FROM tenants`).Scan(&tenantRows); err != nil {
		t.Fatalf("tenant self-discovery on a reused connection: %v", err)
	}
	if tenantRows != 1 {
		t.Errorf("self-discovery saw %d tenants, want 1", tenantRows)
	}
}

// A poisoned connection must not become a way to read another mess. The fix
// turns '' back into NULL, and NULL matches nothing -- fail closed, not open.
func TestEmptyTenantSettingMatchesNothing(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	owner, appDSN := dbtest.NewTestDatabase(ctx, t, "tinbela_guc_failclosed_test")

	if _, err := owner.Exec(ctx,
		`INSERT INTO tenants (id, name, kind)
		 VALUES (gen_random_uuid(), 'অন্য মেস', 'MESS')`); err != nil {
		t.Fatalf("seed tenant: %v", err)
	}

	conn, err := pgx.Connect(ctx, appDSN)
	if err != nil {
		t.Fatalf("connect as %s: %v", dbtest.AppUser, err)
	}
	defer func() { _ = conn.Close(context.WithoutCancel(ctx)) }()

	tx, err := conn.Begin(ctx)
	if err != nil {
		t.Fatalf("begin: %v", err)
	}
	defer func() { _ = tx.Rollback(context.WithoutCancel(ctx)) }()

	// No app.user_id either: nothing identifies this caller at all.
	if _, err := tx.Exec(ctx,
		"SELECT set_config('app.tenant_id', '', true)"); err != nil {
		t.Fatalf("set empty tenant: %v", err)
	}

	var n int
	if err := tx.QueryRow(ctx, `SELECT count(*) FROM tenants`).Scan(&n); err != nil {
		t.Fatalf("read with an empty tenant setting: %v", err)
	}
	if n != 0 {
		t.Errorf("an empty app.tenant_id exposed %d tenants, want 0", n)
	}
}
