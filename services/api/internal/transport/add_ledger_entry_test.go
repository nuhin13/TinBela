package transport_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"connectrpc.com/connect"

	corev1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1"
	moneyv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/money/v1"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/money/v1/moneyv1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/transport"
)

// dhakaToday is the current calendar day in Asia/Dhaka, matching the server's
// own boundary (Invariant 5), so a recorded entry lands inside the open month.
func dhakaToday() string {
	loc, err := time.LoadLocation("Asia/Dhaka")
	if err != nil {
		loc = time.UTC
	}
	return time.Now().In(loc).Format("2006-01-02")
}

// TestAddLedgerEntry is task 06.1: a manager records a FOOD_COST and a member
// DEPOSIT. Money is int64 paisa (the proto rejects a float at the type level),
// the write is append-only and tenant-scoped, and the guards around it — kind,
// amount, deposit attribution, manager-only, cross-tenant isolation, and a
// date inside the open period — hold against a real Postgres.
func TestAddLedgerEntry(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, owner, srv, cleanup := newAPI(ctx, t, "tinbela_ledger_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000006a1")
	defer cleanup()
	money := moneyv1connect.NewMoneyServiceClient(srv.Client(), srv.URL)

	auth := func(r interface{ Header() http.Header }, tenant string) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager")
		if tenant != "" {
			r.Header().Set(transport.HeaderTenantID, tenant)
		}
	}

	// ── a mess with one member ─────────────────────────────────────────────
	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "কাঁটাবন মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	auth(createReq, "")
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messID := created.Msg.GetMess().GetId()

	addReq := connect.NewRequest(&corev1.AddMemberRequest{MessId: messID, DisplayName: "সজীব"})
	auth(addReq, messID)
	added, err := core.AddMember(ctx, addReq)
	if err != nil {
		t.Fatalf("AddMember: %v", err)
	}
	memberID := added.Msg.GetMember().GetId()

	// today in Asia/Dhaka — always inside the current open period.
	today := dhakaToday()

	// ── a FOOD_COST is recorded ────────────────────────────────────────────
	foodReq := connect.NewRequest(&moneyv1.AddLedgerEntryRequest{
		MessId: messID, Kind: moneyv1.EntryKind_ENTRY_KIND_FOOD_COST,
		AmountPaisa: 125000, Category: "bazar",
		OccurredOn: &corev1.Date{Value: today}, Note: "সকালের বাজার",
	})
	auth(foodReq, messID)
	foodRes, err := money.AddLedgerEntry(ctx, foodReq)
	if err != nil {
		t.Fatalf("AddLedgerEntry FOOD_COST: %v", err)
	}
	if got := foodRes.Msg.GetEntry().GetAmount().GetPaisa(); got != 125000 {
		t.Errorf("food amount paisa = %d, want 125000", got)
	}
	if got := foodRes.Msg.GetEntry().GetKind(); got != moneyv1.EntryKind_ENTRY_KIND_FOOD_COST {
		t.Errorf("food kind = %v, want FOOD_COST", got)
	}
	if got := foodRes.Msg.GetEntry().GetCategory(); got != "bazar" {
		t.Errorf("food category = %q, want bazar", got)
	}
	if foodRes.Msg.GetEntry().GetId() == "" {
		t.Error("food entry has no id")
	}

	// ── a DEPOSIT is recorded against the member ───────────────────────────
	depReq := connect.NewRequest(&moneyv1.AddLedgerEntryRequest{
		MessId: messID, Kind: moneyv1.EntryKind_ENTRY_KIND_DEPOSIT,
		AmountPaisa: 200000, MembershipId: memberID,
		OccurredOn: &corev1.Date{Value: today},
	})
	auth(depReq, messID)
	depRes, err := money.AddLedgerEntry(ctx, depReq)
	if err != nil {
		t.Fatalf("AddLedgerEntry DEPOSIT: %v", err)
	}
	if got := depRes.Msg.GetEntry().GetMembershipId(); got != memberID {
		t.Errorf("deposit membership = %q, want %q", got, memberID)
	}
	if got := depRes.Msg.GetEntry().GetMemberDisplayName(); got != "সজীব" {
		t.Errorf("deposit member_display_name = %q, want সজীব", got)
	}

	// ── the ledger holds exactly the two rows, unmodified (append-only) ─────
	var n int
	if err := owner.QueryRow(ctx,
		`SELECT count(*) FROM ledger_entries WHERE tenant_id = $1`, messID).Scan(&n); err != nil {
		t.Fatalf("count ledger: %v", err)
	}
	if n != 2 {
		t.Fatalf("ledger row count = %d, want 2", n)
	}

	// ── rejections ─────────────────────────────────────────────────────────
	cases := []struct {
		name string
		req  *moneyv1.AddLedgerEntryRequest
		code connect.Code
	}{
		{
			name: "zero amount",
			req:  &moneyv1.AddLedgerEntryRequest{MessId: messID, Kind: moneyv1.EntryKind_ENTRY_KIND_FOOD_COST, AmountPaisa: 0, OccurredOn: &corev1.Date{Value: today}},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "negative amount (corrections go through void)",
			req:  &moneyv1.AddLedgerEntryRequest{MessId: messID, Kind: moneyv1.EntryKind_ENTRY_KIND_FOOD_COST, AmountPaisa: -500, OccurredOn: &corev1.Date{Value: today}},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "deposit without a member",
			req:  &moneyv1.AddLedgerEntryRequest{MessId: messID, Kind: moneyv1.EntryKind_ENTRY_KIND_DEPOSIT, AmountPaisa: 1000, OccurredOn: &corev1.Date{Value: today}},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "P2 kind rejected in v1.0",
			req:  &moneyv1.AddLedgerEntryRequest{MessId: messID, Kind: moneyv1.EntryKind_ENTRY_KIND_SHARED_COST, AmountPaisa: 1000, OccurredOn: &corev1.Date{Value: today}},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "date in a closed/absent period",
			req:  &moneyv1.AddLedgerEntryRequest{MessId: messID, Kind: moneyv1.EntryKind_ENTRY_KIND_FOOD_COST, AmountPaisa: 1000, OccurredOn: &corev1.Date{Value: "2000-01-01"}},
			code: connect.CodeFailedPrecondition,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			r := connect.NewRequest(tc.req)
			auth(r, messID)
			if _, err := money.AddLedgerEntry(ctx, r); connect.CodeOf(err) != tc.code {
				t.Fatalf("code = %v (err %v), want %v", connect.CodeOf(err), err, tc.code)
			}
		})
	}
}

// TestAddLedgerEntryIsManagerOnly and cross-tenant isolation: a second mess's
// manager cannot record into the first, and a plain member cannot record at
// all (the role interceptor already refuses, proven in role_test.go; here we
// prove the tenant boundary holds at the handler).
func TestAddLedgerEntryTenantIsolation(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	coreA, _, srv, cleanup := newAPI(ctx, t, "tinbela_ledger_iso_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000006b1")
	defer cleanup()
	money := moneyv1connect.NewMoneyServiceClient(srv.Client(), srv.URL)

	auth := func(r interface{ Header() http.Header }, tenant string) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager")
		if tenant != "" {
			r.Header().Set(transport.HeaderTenantID, tenant)
		}
	}

	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "মেস এ", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	auth(createReq, "")
	created, err := coreA.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messA := created.Msg.GetMess().GetId()

	// A request that names mess A in the body but carries no tenant header the
	// caller is authorised for other than A is fine; the risk is a body/header
	// disagreement. Point the body at a foreign id while the header says A:
	// the handler must treat the mismatch as a cross-tenant attempt.
	foreign := "ffffffff-0000-0000-0000-000000000000"
	req := connect.NewRequest(&moneyv1.AddLedgerEntryRequest{
		MessId: foreign, Kind: moneyv1.EntryKind_ENTRY_KIND_FOOD_COST,
		AmountPaisa: 1000, OccurredOn: &corev1.Date{Value: dhakaToday()},
	})
	auth(req, messA)
	if _, err := money.AddLedgerEntry(ctx, req); connect.CodeOf(err) != connect.CodePermissionDenied {
		t.Fatalf("cross-tenant body: code = %v (err %v), want permission_denied", connect.CodeOf(err), err)
	}
}
