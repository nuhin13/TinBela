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

// TestSetPatterns is task 05.2: a manager records a member's weekly default —
// which slots, which days, how many plates. A new member needs none of this to
// be correct (the engine defaults a missing pattern to on/every-day/one plate);
// SetPatterns only stores a deliberate change, and re-setting the same slot on
// the same day updates the row rather than appending a duplicate.
func TestSetPatterns(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, owner, srv, cleanup := newAPI(ctx, t, "tinbela_patterns_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000005c1")
	defer cleanup()
	meals := mealsv1connect.NewMealsServiceClient(srv.Client(), srv.URL)

	auth := func(r interface{ Header() http.Header }, tenant string) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager")
		if tenant != "" {
			r.Header().Set(transport.HeaderTenantID, tenant)
		}
	}

	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "বাড্ডা মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	auth(createReq, "")
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messID := created.Msg.GetMess().GetId()

	addReq := connect.NewRequest(&corev1.AddMemberRequest{MessId: messID, DisplayName: "তানভীর"})
	auth(addReq, messID)
	added, err := core.AddMember(ctx, addReq)
	if err != nil {
		t.Fatalf("AddMember: %v", err)
	}
	memberID := added.Msg.GetMember().GetId()

	// breakfast (first slot) and dinner (last slot).
	var breakfast, dinner string
	if err := owner.QueryRow(ctx,
		`SELECT id FROM slots WHERE tenant_id = $1 ORDER BY sort_order LIMIT 1`, messID).Scan(&breakfast); err != nil {
		t.Fatalf("read breakfast slot: %v", err)
	}
	if err := owner.QueryRow(ctx,
		`SELECT id FROM slots WHERE tenant_id = $1 ORDER BY sort_order DESC LIMIT 1`, messID).Scan(&dinner); err != nil {
		t.Fatalf("read dinner slot: %v", err)
	}

	// ── set: never breakfast (dow_mask 0), always double dinner (qty 2) ─────
	setReq := connect.NewRequest(&mealsv1.SetPatternsRequest{
		MessId: messID, MembershipId: memberID,
		Patterns: []*mealsv1.Pattern{
			{SlotId: breakfast, DowMask: 0, Qty: 1},
			{SlotId: dinner, DowMask: 127, Qty: 2},
		},
	})
	auth(setReq, messID)
	setRes, err := meals.SetPatterns(ctx, setReq)
	if err != nil {
		t.Fatalf("SetPatterns: %v", err)
	}
	if got := len(setRes.Msg.GetPatterns()); got != 2 {
		t.Fatalf("returned %d patterns, want 2", got)
	}

	// Two rows persisted, effective today, with the values we set.
	var n int
	if err := owner.QueryRow(ctx,
		`SELECT count(*) FROM patterns WHERE tenant_id = $1 AND membership_id = $2`, messID, memberID).Scan(&n); err != nil {
		t.Fatalf("count patterns: %v", err)
	}
	if n != 2 {
		t.Fatalf("pattern row count = %d, want 2", n)
	}
	var dinnerQty, dinnerDow int
	if err := owner.QueryRow(ctx,
		`SELECT qty, dow_mask FROM patterns WHERE tenant_id = $1 AND membership_id = $2 AND slot_id = $3`,
		messID, memberID, dinner).Scan(&dinnerQty, &dinnerDow); err != nil {
		t.Fatalf("read dinner pattern: %v", err)
	}
	if dinnerQty != 2 || dinnerDow != 127 {
		t.Errorf("dinner pattern = qty %d dow %d, want qty 2 dow 127", dinnerQty, dinnerDow)
	}

	// ── upsert: re-set dinner the same day updates, does not duplicate ──────
	reReq := connect.NewRequest(&mealsv1.SetPatternsRequest{
		MessId: messID, MembershipId: memberID,
		Patterns: []*mealsv1.Pattern{{SlotId: dinner, DowMask: 127, Qty: 1}},
	})
	auth(reReq, messID)
	if _, err := meals.SetPatterns(ctx, reReq); err != nil {
		t.Fatalf("SetPatterns (re-set): %v", err)
	}
	if err := owner.QueryRow(ctx,
		`SELECT count(*) FROM patterns WHERE tenant_id = $1 AND membership_id = $2`, messID, memberID).Scan(&n); err != nil {
		t.Fatalf("re-count patterns: %v", err)
	}
	if n != 2 {
		t.Fatalf("after re-set, pattern row count = %d, want 2 (upsert, not append)", n)
	}
	if err := owner.QueryRow(ctx,
		`SELECT qty FROM patterns WHERE tenant_id = $1 AND membership_id = $2 AND slot_id = $3`,
		messID, memberID, dinner).Scan(&dinnerQty); err != nil {
		t.Fatalf("re-read dinner pattern: %v", err)
	}
	if dinnerQty != 1 {
		t.Errorf("dinner qty after re-set = %d, want 1", dinnerQty)
	}

	// ── rejections ─────────────────────────────────────────────────────────
	cases := []struct {
		name string
		req  *mealsv1.SetPatternsRequest
		code connect.Code
	}{
		{
			name: "member not in this mess",
			req:  &mealsv1.SetPatternsRequest{MessId: messID, MembershipId: "ffffffff-0000-0000-0000-000000000000", Patterns: []*mealsv1.Pattern{{SlotId: dinner, DowMask: 127, Qty: 1}}},
			code: connect.CodeNotFound,
		},
		{
			name: "foreign slot",
			req:  &mealsv1.SetPatternsRequest{MessId: messID, MembershipId: memberID, Patterns: []*mealsv1.Pattern{{SlotId: "ffffffff-0000-0000-0000-000000000000", DowMask: 127, Qty: 1}}},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "dow_mask out of range",
			req:  &mealsv1.SetPatternsRequest{MessId: messID, MembershipId: memberID, Patterns: []*mealsv1.Pattern{{SlotId: dinner, DowMask: 200, Qty: 1}}},
			code: connect.CodeInvalidArgument,
		},
		{
			name: "qty out of range",
			req:  &mealsv1.SetPatternsRequest{MessId: messID, MembershipId: memberID, Patterns: []*mealsv1.Pattern{{SlotId: dinner, DowMask: 127, Qty: 50}}},
			code: connect.CodeInvalidArgument,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			r := connect.NewRequest(tc.req)
			auth(r, messID)
			if _, err := meals.SetPatterns(ctx, r); connect.CodeOf(err) != tc.code {
				t.Fatalf("code = %v (err %v), want %v", connect.CodeOf(err), err, tc.code)
			}
		})
	}
}
