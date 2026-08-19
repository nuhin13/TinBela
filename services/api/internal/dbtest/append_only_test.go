// Package dbtest proves the database enforces what the application
// assumes.
//
// These tests live outside internal/db on purpose: that directory is
// sqlc-generated, and hand-written files there are blocked by
// .claude/hooks/pre-edit-guard.sh.
package dbtest

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
)

// TestAppendOnlyTables is the other half of Epic 01's gate: a write that
// would mutate history is silently discarded.
//
// The three protected tables carry DO INSTEAD NOTHING rules for UPDATE and
// DELETE (000001). "Silently" is the important word -- these statements do
// not raise, they report zero rows affected and change nothing. Application
// code that trusted an error to surface a bad write would never hear about
// it, which is exactly why this is asserted rather than assumed.
func TestAppendOnlyTables(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	owner, _ := NewTestDatabase(ctx, t, "tinbela_append_only_test")
	fx := seedProtectedRows(ctx, t, owner)

	cases := []struct {
		table     string
		id        string
		update    string
		readBack  string
		wantValue string
	}{
		{
			table:     "meal_exceptions",
			id:        fx.exceptionID,
			update:    "UPDATE meal_exceptions SET action = 'ON' WHERE id = '%s'", // ignore: append-only-test
			readBack:  "SELECT action FROM meal_exceptions WHERE id = '%s'",
			wantValue: "OFF",
		},
		{
			table:     "ledger_entries",
			id:        fx.ledgerID,
			update:    "UPDATE ledger_entries SET amount_paisa = 999999 WHERE id = '%s'", // ignore: append-only-test
			readBack:  "SELECT amount_paisa::text FROM ledger_entries WHERE id = '%s'",
			wantValue: "150000",
		},
		{
			table:     "period_statements",
			id:        fx.statementID,
			update:    "UPDATE period_statements SET balance_paisa = 999999 WHERE id = '%s'", // ignore: append-only-test
			readBack:  "SELECT balance_paisa::text FROM period_statements WHERE id = '%s'",
			wantValue: "-50000",
		},
	}

	for _, tc := range cases {
		t.Run(tc.table, func(t *testing.T) {
			t.Run("update is a silent no-op", func(t *testing.T) {
				tag, err := owner.Exec(ctx, fmt.Sprintf(tc.update, tc.id))
				if err != nil {
					t.Fatalf("UPDATE raised %v; the rule should discard it silently", err)
				}
				if n := tag.RowsAffected(); n != 0 {
					t.Errorf("UPDATE affected %d rows, want 0", n)
				}
				if got := scalar(ctx, t, owner, fmt.Sprintf(tc.readBack, tc.id)); got != tc.wantValue {
					t.Errorf("value is %q after UPDATE, want %q unchanged", got, tc.wantValue)
				}
			})

			t.Run("delete is a silent no-op", func(t *testing.T) {
				tag, err := owner.Exec(ctx,
					fmt.Sprintf("DELETE FROM %s WHERE id = '%s'", tc.table, tc.id))
				if err != nil {
					t.Fatalf("DELETE raised %v; the rule should discard it silently", err)
				}
				if n := tag.RowsAffected(); n != 0 {
					t.Errorf("DELETE affected %d rows, want 0", n)
				}
				still := scalar(ctx, t, owner,
					fmt.Sprintf("SELECT count(*)::text FROM %s WHERE id = '%s'", tc.table, tc.id))
				if still != "1" {
					t.Errorf("row count is %s after DELETE, want 1", still)
				}
			})
		})
	}

	// The sanctioned correction path: insert a new row pointing at the old
	// one. If this ever breaks, the append-only design has no escape hatch
	// and operators will reach for UPDATE.
	t.Run("correction by void_of insert", func(t *testing.T) {
		_, err := owner.Exec(ctx, fmt.Sprintf(`
			INSERT INTO ledger_entries
				(id, tenant_id, kind, amount_paisa, occurred_on, entered_by, void_of)
			VALUES (gen_random_uuid(), '%s', 'FOOD_COST', -150000, DATE '2026-01-01',
				'%s', '%s')`, tenantA, probeUser, fx.ledgerID))
		if err != nil {
			t.Fatalf("void_of correction rejected: %v", err)
		}
		if got := scalar(ctx, t, owner, fmt.Sprintf(
			`SELECT sum(amount_paisa)::text FROM ledger_entries WHERE id = '%s' OR void_of = '%s'`,
			fx.ledgerID, fx.ledgerID)); got != "0" {
			t.Errorf("entry plus its void sums to %s, want 0", got)
		}
	})
}

type protectedFixture struct {
	exceptionID, ledgerID, statementID string
}

func seedProtectedRows(ctx context.Context, t *testing.T, conn *pgx.Conn) protectedFixture {
	t.Helper()
	const (
		membershipID = "dddddddd-0000-0000-0000-000000000001"
		periodID     = "dddddddd-0000-0000-0000-000000000002"
	)
	fx := protectedFixture{
		exceptionID: "eeeeeeee-0000-0000-0000-000000000001",
		ledgerID:    "eeeeeeee-0000-0000-0000-000000000002",
		statementID: "eeeeeeee-0000-0000-0000-000000000003",
	}

	for _, s := range []string{
		fmt.Sprintf(`INSERT INTO users (id, name) VALUES ('%s', 'append probe')`, probeUser),
		fmt.Sprintf(`INSERT INTO tenants (id, name, kind) VALUES ('%s', 'mess', 'MESS')`, tenantA),
		fmt.Sprintf(`INSERT INTO memberships
			(id, tenant_id, user_id, role, display_name, joined_at)
			VALUES ('%s', '%s', '%s', 'MEMBER', 'm', DATE '2026-01-01')`,
			membershipID, tenantA, probeUser),
		fmt.Sprintf(`INSERT INTO periods (id, tenant_id, start_date, end_date, status)
			VALUES ('%s', '%s', DATE '2026-01-01', DATE '2026-01-31', 'CLOSED')`,
			periodID, tenantA),
		fmt.Sprintf(`INSERT INTO meal_exceptions
			(id, tenant_id, membership_id, date_from, date_to, action, marked_by)
			VALUES ('%s', '%s', '%s', DATE '2026-01-05', DATE '2026-01-05', 'OFF', '%s')`,
			fx.exceptionID, tenantA, membershipID, probeUser),
		fmt.Sprintf(`INSERT INTO ledger_entries
			(id, tenant_id, kind, amount_paisa, occurred_on, entered_by)
			VALUES ('%s', '%s', 'FOOD_COST', 150000, DATE '2026-01-01', '%s')`,
			fx.ledgerID, tenantA, probeUser),
		fmt.Sprintf(`INSERT INTO period_statements
			(id, tenant_id, period_id, membership_id, meals_qty, meal_rate_paisa,
			 food_cost_paisa, deposits_paisa, balance_paisa, closed_at)
			VALUES ('%s', '%s', '%s', '%s', 60, 5000, 300000, 250000, -50000, now())`,
			fx.statementID, tenantA, periodID, membershipID),
	} {
		if _, err := conn.Exec(ctx, s); err != nil {
			t.Fatalf("fixture: %v", err)
		}
	}
	return fx
}

func scalar(ctx context.Context, t *testing.T, conn *pgx.Conn, query string) string {
	t.Helper()
	var v string
	if err := conn.QueryRow(ctx, query).Scan(&v); err != nil {
		t.Fatalf("query %q: %v", query, err)
	}
	return v
}
