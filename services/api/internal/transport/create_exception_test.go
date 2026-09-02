package transport_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"connectrpc.com/connect"

	corev1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1"
	mealsv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/meals/v1"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/meals/v1/mealsv1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/transport"
)

// TestCreateException is task 05.3: a manager records a meal exception —
// someone OFF, or a guest — as an append-only row. The write is tenant-scoped
// and manager-only; the action/qty/date/slot guards hold against a real
// Postgres. Cutoff enforcement and the after_cutoff audit flag are task 05.6 ★
// / 05.7 and are deliberately not asserted here.
func TestCreateException(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, owner, srv, cleanup := newAPI(ctx, t, "tinbela_exception_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000005a1")
	defer cleanup()
	meals := mealsv1connect.NewMealsServiceClient(srv.Client(), srv.URL)

	auth := func(r interface{ Header() http.Header }, tenant string) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager")
		if tenant != "" {
			r.Header().Set(transport.HeaderTenantID, tenant)
		}
	}

	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "চকবাজার মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	auth(createReq, "")
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messID := created.Msg.GetMess().GetId()

	addReq := connect.NewRequest(&corev1.AddMemberRequest{MessId: messID, DisplayName: "নাদিম"})
	auth(addReq, messID)
	added, err := core.AddMember(ctx, addReq)
	if err != nil {
		t.Fatalf("AddMember: %v", err)
	}
	memberID := added.Msg.GetMember().GetId()

	// A real slot id from this mess, for the slot-specific case below.
	var slotID string
	if err := owner.QueryRow(ctx,
		`SELECT id FROM slots WHERE tenant_id = $1 ORDER BY sort_order LIMIT 1`, messID).Scan(&slotID); err != nil {
		t.Fatalf("read slot: %v", err)
	}
	today := dhakaToday()

	// ── OFF for a single day, every slot (slot_id empty) ────────────────────
	offReq := connect.NewRequest(&mealsv1.CreateExceptionRequest{
		MessId: messID, MembershipId: memberID,
		DateFrom: &corev1.Date{Value: today},
		Action:   mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF,
	})
	auth(offReq, messID)
	offRes, err := meals.CreateException(ctx, offReq)
	if err != nil {
		t.Fatalf("CreateException OFF: %v", err)
	}
	ex := offRes.Msg.GetException()
	if ex.GetAction() != mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF {
		t.Errorf("action = %v, want OFF", ex.GetAction())
	}
	if ex.GetMemberDisplayName() != "নাদিম" {
		t.Errorf("member_display_name = %q, want নাদিম", ex.GetMemberDisplayName())
	}
	if ex.GetRange().GetFrom().GetValue() != today || ex.GetRange().GetTo().GetValue() != today {
		t.Errorf("range = %v..%v, want %s (to defaults to from)", ex.GetRange().GetFrom().GetValue(), ex.GetRange().GetTo().GetValue(), today)
	}
	if ex.GetId() == "" {
		t.Error("exception has no id")
	}

	// ── GUEST +2 on one slot, over a two-day range ──────────────────────────
	tomorrow := time.Now().Add(24 * time.Hour).Format("2006-01-02")
	guestReq := connect.NewRequest(&mealsv1.CreateExceptionRequest{
		MessId: messID, MembershipId: memberID, SlotId: slotID,
		DateFrom: &corev1.Date{Value: today}, DateTo: &corev1.Date{Value: tomorrow},
		Action: mealsv1.ExceptionAction_EXCEPTION_ACTION_GUEST, Qty: 2,
	})
	auth(guestReq, messID)
	guestRes, err := meals.CreateException(ctx, guestReq)
	if err != nil {
		t.Fatalf("CreateException GUEST: %v", err)
	}
	if got := guestRes.Msg.GetException().GetQty(); got != 2 {
		t.Errorf("guest qty = %d, want 2", got)
	}
	if got := guestRes.Msg.GetException().GetSlotId(); got != slotID {
		t.Errorf("guest slot = %q, want %q", got, slotID)
	}

	// ── two append-only rows, nothing updated ───────────────────────────────
	var n int
	if err := owner.QueryRow(ctx,
		`SELECT count(*) FROM meal_exceptions WHERE tenant_id = $1`, messID).Scan(&n); err != nil {
		t.Fatalf("count exceptions: %v", err)
	}
	if n != 2 {
		t.Fatalf("meal_exceptions row count = %d, want 2", n)
	}

	// ── rejections ─────────────────────────────────────────────────────────
	cases := []struct {
		name string
		req  *mealsv1.CreateExceptionRequest
		code connect.Code
	}{
		{
			name: "unspecified action",
			req:  &mealsv1.CreateExceptionRequest{MessId: messID, MembershipId: memberID, DateFrom: &corev1.Date{Value: today}},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "guest without a qty",
			req:  &mealsv1.CreateExceptionRequest{MessId: messID, MembershipId: memberID, DateFrom: &corev1.Date{Value: today}, Action: mealsv1.ExceptionAction_EXCEPTION_ACTION_GUEST, Qty: 0},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "range end before start",
			req:  &mealsv1.CreateExceptionRequest{MessId: messID, MembershipId: memberID, DateFrom: &corev1.Date{Value: today}, DateTo: &corev1.Date{Value: "2000-01-01"}, Action: mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "member not in this mess",
			req:  &mealsv1.CreateExceptionRequest{MessId: messID, MembershipId: "ffffffff-0000-0000-0000-000000000000", DateFrom: &corev1.Date{Value: today}, Action: mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF},
			code: connect.CodeNotFound,
		},
		{
			name: "slot from no known tenant",
			req:  &mealsv1.CreateExceptionRequest{MessId: messID, MembershipId: memberID, SlotId: "ffffffff-0000-0000-0000-000000000000", DateFrom: &corev1.Date{Value: today}, Action: mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF},
			code: connect.CodeInvalidArgument,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			r := connect.NewRequest(tc.req)
			auth(r, messID)
			if _, err := meals.CreateException(ctx, r); connect.CodeOf(err) != tc.code {
				t.Fatalf("code = %v (err %v), want %v", connect.CodeOf(err), err, tc.code)
			}
		})
	}
}

// TestCreateExceptionTenantIsolation: a body that names a foreign mess while
// the header authorises this one is treated as a cross-tenant attempt.
func TestCreateExceptionTenantIsolation(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, _, srv, cleanup := newAPI(ctx, t, "tinbela_exception_iso_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000005b1")
	defer cleanup()
	meals := mealsv1connect.NewMealsServiceClient(srv.Client(), srv.URL)

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
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messA := created.Msg.GetMess().GetId()

	req := connect.NewRequest(&mealsv1.CreateExceptionRequest{
		MessId: "ffffffff-0000-0000-0000-000000000000", MembershipId: "ffffffff-0000-0000-0000-000000000001",
		DateFrom: &corev1.Date{Value: dhakaToday()}, Action: mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF,
	})
	auth(req, messA)
	if _, err := meals.CreateException(ctx, req); connect.CodeOf(err) != connect.CodePermissionDenied {
		t.Fatalf("cross-tenant body: code = %v (err %v), want permission_denied", connect.CodeOf(err), err)
	}
}
