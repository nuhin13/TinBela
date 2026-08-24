package transport_test

// Epic 04 task 04.7 -- "Member cannot write ledger; test proves it."
//
// The proof has to be end to end. A unit test on the interceptor would show
// that a function returns permission_denied; only a real call through the
// mounted chain shows that the interceptor is actually in the chain, in the
// right position, ahead of the handler.

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

const (
	managerUID = "dev-manager"
	memberUID  = "dev-member"
	memberID   = "aaaa0000-0000-0000-0000-0000000004b7"
)

func TestMemberCannotWriteLedger(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, owner, srv, cleanup := newAPI(ctx, t,
		"tinbela_role_test", managerUID, "aaaa0000-0000-0000-0000-0000000004a7")
	defer cleanup()

	money := moneyv1connect.NewMoneyServiceClient(srv.Client(), srv.URL)

	as := func(uid, tenant string) func(interface{ Header() http.Header }) {
		return func(r interface{ Header() http.Header }) {
			r.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+uid)
			if tenant != "" {
				r.Header().Set(transport.HeaderTenantID, tenant)
			}
		}
	}

	// ── a mess with a manager and one ordinary member ──────────────────
	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "রোল টেস্ট মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	as(managerUID, "")(createReq)
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messID := created.Msg.GetMess().GetId()

	addReq := connect.NewRequest(&corev1.AddMemberRequest{
		MessId: messID, DisplayName: "রহিম",
	})
	as(managerUID, messID)(addReq)
	if _, err := core.AddMember(ctx, addReq); err != nil {
		t.Fatalf("AddMember: %v", err)
	}

	// The member opens their invite link and gets an account.
	seedUser(ctx, t, owner, memberID, memberUID, "রহিম")
	claimInvite(ctx, t, owner, messID, "রহিম", memberID)

	// ── the proof ──────────────────────────────────────────────────────
	entry := func() *connect.Request[moneyv1.AddLedgerEntryRequest] {
		return connect.NewRequest(&moneyv1.AddLedgerEntryRequest{MessId: messID})
	}

	memberWrite := entry()
	as(memberUID, messID)(memberWrite)
	_, err = money.AddLedgerEntry(ctx, memberWrite)
	if got := connect.CodeOf(err); got != connect.CodePermissionDenied {
		t.Fatalf("member AddLedgerEntry: code = %v (err %v), want permission_denied", got, err)
	}

	// The rejection must come from the role check, not from the handler
	// being a stub. A manager reaches the stub and is told "unimplemented" --
	// which is exactly how we know the member never reached it.
	managerWrite := entry()
	as(managerUID, messID)(managerWrite)
	_, err = money.AddLedgerEntry(ctx, managerWrite)
	if got := connect.CodeOf(err); got != connect.CodeUnimplemented {
		t.Fatalf("manager AddLedgerEntry: code = %v (err %v), want unimplemented (Epic 06 stub)", got, err)
	}

	// And the member is not simply locked out of the mess: reading is the
	// half of the role that still works.
	listReq := connect.NewRequest(&corev1.ListMembersRequest{MessId: messID})
	as(memberUID, messID)(listReq)
	listed, err := core.ListMembers(ctx, listReq)
	if err != nil {
		t.Fatalf("member ListMembers: %v", err)
	}
	if n := len(listed.Msg.GetMembers()); n != 2 {
		t.Errorf("members visible to a member = %d, want 2 (the manager and themselves)", n)
	}
}

// A procedure nobody has classified must be manager-only. This test fails
// the day someone adds a member-facing RPC and forgets to list it, which is
// the point: a loud permission_denied beats a silent hole.
func TestUnlistedProceduresAreManagerOnly(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, owner, srv, cleanup := newAPI(ctx, t,
		"tinbela_role_default_test", managerUID, "aaaa0000-0000-0000-0000-0000000004a8")
	defer cleanup()

	money := moneyv1connect.NewMoneyServiceClient(srv.Client(), srv.URL)

	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "ডিফল্ট টেস্ট মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	createReq.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+managerUID)
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messID := created.Msg.GetMess().GetId()

	addReq := connect.NewRequest(&corev1.AddMemberRequest{MessId: messID, DisplayName: "করিম"})
	addReq.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+managerUID)
	addReq.Header().Set(transport.HeaderTenantID, messID)
	if _, err := core.AddMember(ctx, addReq); err != nil {
		t.Fatalf("AddMember: %v", err)
	}
	seedUser(ctx, t, owner, memberID, memberUID, "করিম")
	claimInvite(ctx, t, owner, messID, "করিম", memberID)

	// ClosePeriod is on no list. It must therefore be denied to a member.
	closeReq := connect.NewRequest(&moneyv1.ClosePeriodRequest{MessId: messID})
	closeReq.Header().Set(transport.HeaderAuthorization, "Bearer dev:"+memberUID)
	closeReq.Header().Set(transport.HeaderTenantID, messID)
	if _, err := money.ClosePeriod(ctx, closeReq); connect.CodeOf(err) != connect.CodePermissionDenied {
		t.Fatalf("member ClosePeriod: code = %v (err %v), want permission_denied", connect.CodeOf(err), err)
	}
}
