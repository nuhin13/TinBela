package transport_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/google/uuid"

	corev1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1"
	"github.com/droidbuilder/tinbela/services/api/internal/transport"
)

// TestPeriodLifecycle is task 07.1: a mess opens its first period automatically
// on creation, and the database refuses a second period that overlaps it. The
// non-overlap guard is a Postgres EXCLUDE constraint (migration 000001), not
// application code — so it holds even against a raw insert that skips the API.
func TestPeriodLifecycle(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, owner, _, cleanup := newAPI(ctx, t, "tinbela_period_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000007a1")
	defer cleanup()

	auth := func(r interface{ Header() http.Header }, tenant string) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager")
		if tenant != "" {
			r.Header().Set(transport.HeaderTenantID, tenant)
		}
	}

	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "মোহাম্মদপুর মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	auth(createReq, "")
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messID := created.Msg.GetMess().GetId()

	// ── auto-open: exactly one OPEN period, and it contains today ───────────
	var (
		count      int
		status     string
		start, end time.Time
	)
	if err := owner.QueryRow(ctx,
		`SELECT count(*) FROM periods WHERE tenant_id = $1`, messID).Scan(&count); err != nil {
		t.Fatalf("count periods: %v", err)
	}
	if count != 1 {
		t.Fatalf("period count = %d, want 1 (auto-opened on creation)", count)
	}
	if err := owner.QueryRow(ctx,
		`SELECT status, start_date, end_date FROM periods WHERE tenant_id = $1`, messID).
		Scan(&status, &start, &end); err != nil {
		t.Fatalf("read period: %v", err)
	}
	if status != "OPEN" {
		t.Errorf("period status = %q, want OPEN", status)
	}
	// The current period must also match the mess's reported current_period_id.
	if created.Msg.GetMess().GetCurrentPeriodId() == "" {
		t.Error("CreateMess did not report a current_period_id")
	}

	// ── non-overlap: a second period inside the first is refused by the DB ──
	// A date squarely inside the open period; both endpoints land in-range.
	mid := start.AddDate(0, 0, 1)
	if mid.After(end) {
		mid = start // a one-day period still overlaps
	}
	_, err = owner.Exec(ctx,
		`INSERT INTO periods (id, tenant_id, start_date, end_date, status)
		 VALUES ($1, $2, $3, $4, 'OPEN')`,
		uuid.New(), messID, start, mid)
	if err == nil {
		t.Fatal("an overlapping period insert succeeded; the EXCLUDE constraint did not hold")
	}

	// ── a non-overlapping period (a later month) is allowed ────────────────
	nextStart := end.AddDate(0, 0, 1)
	nextEnd := nextStart.AddDate(0, 1, -1)
	if _, err := owner.Exec(ctx,
		`INSERT INTO periods (id, tenant_id, start_date, end_date, status)
		 VALUES ($1, $2, $3, $4, 'OPEN')`,
		uuid.New(), messID, nextStart, nextEnd); err != nil {
		t.Fatalf("a non-overlapping period should insert cleanly: %v", err)
	}
}
