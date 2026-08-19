package db

import (
	"context"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"testing"

	"github.com/jackc/pgx/v5"
)

const (
	ownerDSNDefault = "postgres://tinbela:tinbela@localhost:5432/tinbela?sslmode=disable"
	appUser         = "tinbela_app"
	appPassword     = "tinbela_app" // dev only; see migration 000003
)

// ownerDSN is the migrating role's DSN: the owner, which is also a superuser
// in dev. Tests that need to prove RLS must connect as appUser instead.
func ownerDSN() string {
	if dsn := os.Getenv("PG_DSN"); dsn != "" {
		return dsn
	}
	return ownerDSNDefault
}

// dsnFor rewrites a DSN to point at another database, optionally as another
// role.
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

// newTestDatabase creates a migrated database of its own and returns an owner
// connection to it plus the DSN the application role would use.
//
// Each test gets a fresh database rather than sharing the dev one, because the
// dev one cannot be cleaned up: the append-only DO INSTEAD NOTHING rules break
// ON DELETE CASCADE, so a tenant holding ledger rows can never be removed.
// See docs/eng/indexes.md.
func newTestDatabase(ctx context.Context, t *testing.T, name string) (*pgx.Conn, string) {
	t.Helper()

	admin, err := connectSimple(ctx, dsnFor(t, ownerDSN(), "postgres", "", ""))
	if err != nil {
		t.Skipf("postgres unavailable, skipping: %v", err)
	}

	if _, err := admin.Exec(ctx, "DROP DATABASE IF EXISTS "+name); err != nil {
		t.Fatalf("drop %s: %v", name, err)
	}
	if _, err := admin.Exec(ctx, "CREATE DATABASE "+name); err != nil {
		t.Fatalf("create %s: %v", name, err)
	}

	owner, err := connectSimple(ctx, dsnFor(t, ownerDSN(), name, "", ""))
	if err != nil {
		t.Fatalf("connect to %s: %v", name, err)
	}
	applyMigrations(ctx, t, owner)

	t.Cleanup(func() {
		ctx := context.WithoutCancel(ctx)
		_ = owner.Close(ctx)
		if _, err := admin.Exec(ctx, "DROP DATABASE IF EXISTS "+name); err != nil {
			t.Logf("cleanup: dropping %s: %v", name, err)
		}
		_ = admin.Close(ctx)
	})

	return owner, dsnFor(t, ownerDSN(), name, appUser, appPassword)
}

func applyMigrations(ctx context.Context, t *testing.T, conn *pgx.Conn) {
	t.Helper()
	files, err := filepath.Glob(filepath.Join("..", "..", "migrations", "*.up.sql"))
	if err != nil || len(files) == 0 {
		t.Fatalf("no migrations found: %v", err)
	}
	sort.Strings(files)
	for _, f := range files {
		sqlBytes, err := os.ReadFile(f)
		if err != nil {
			t.Fatalf("read %s: %v", f, err)
		}
		if _, err := conn.Exec(ctx, string(sqlBytes)); err != nil {
			t.Fatalf("apply %s: %v", filepath.Base(f), err)
		}
	}
}
