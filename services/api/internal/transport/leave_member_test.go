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

// TestLeaveMember is task 04.8: a soft leave sets left_at, keeps every prior
// meal, and is manager-only and tenant-scoped. P8 (the tenure boundary) is an
// engine property; here we prove the API records the boundary and deletes
// nothing, which is the half of P8 the API owns.
func TestLeaveMember(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, owner, _, cleanup := newAPI(ctx, t, "tinbela_leave_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000048a1")
	defer cleanup()

	auth := func(r interface{ Header() http.Header }, tenant string) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager")
		if tenant != "" {
			r.Header().Set(transport.HeaderTenantID, tenant)
		}
	}

	// ── a mess with one member ─────────────────────────────────────────────
	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "নীলক্ষেত মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	auth(createReq, "")
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}
	messID := created.Msg.GetMess().GetId()

	addReq := connect.NewRequest(&corev1.AddMemberRequest{MessId: messID, DisplayName: "রুবেল"})
	auth(addReq, messID)
	added, err := core.AddMember(ctx, addReq)
	if err != nil {
		t.Fatalf("AddMember: %v", err)
	}
	memberID := added.Msg.GetMember().GetId()

	// A meal the member ate while present. Inserted as the owner (bypasses
	// RLS): there is no CreateException RPC yet (Epic 05), and the point here
	// is only that leaving does not erase it.
	if _, err := owner.Exec(ctx,
		`INSERT INTO meal_exceptions
		   (id, tenant_id, membership_id, slot_id, date_from, date_to, action, marked_by)
		 VALUES ($1, $2, $3, NULL, '2026-08-01', '2026-08-01', 'OFF',
		         'aaaa0000-0000-0000-0000-0000000048a1')`,
		uuid.New(), messID, memberID); err != nil {
		t.Fatalf("seed prior meal: %v", err)
	}

	// ── the leave ──────────────────────────────────────────────────────────
	leaveReq := connect.NewRequest(&corev1.LeaveMemberRequest{MessId: messID, MemberId: memberID})
	auth(leaveReq, messID)
	left, err := core.LeaveMember(ctx, leaveReq)
	if err != nil {
		t.Fatalf("LeaveMember: %v", err)
	}
	if got := left.Msg.GetMember().GetLeftAt().GetValue(); got == "" {
		t.Error("left_at was not set on the returned member")
	}

	// Prior meals still count: the row is untouched, not cascade-deleted.
	var meals int
	if err := owner.QueryRow(ctx,
		`SELECT count(*) FROM meal_exceptions WHERE membership_id = $1`, memberID).
		Scan(&meals); err != nil {
		t.Fatalf("count meals: %v", err)
	}
	if meals != 1 {
		t.Errorf("prior meals after leaving = %d, want 1 (soft leave never deletes history)", meals)
	}

	// The membership itself is still there, now flagged left.
	var leftAt *time.Time
	if err := owner.QueryRow(ctx,
		`SELECT left_at FROM memberships WHERE id = $1`, memberID).Scan(&leftAt); err != nil {
		t.Fatalf("read membership: %v", err)
	}
	if leftAt == nil {
		t.Error("membership.left_at is still NULL after LeaveMember")
	}

	t.Run("leaving twice is refused, not a silent no-op", func(t *testing.T) {
		req := connect.NewRequest(&corev1.LeaveMemberRequest{MessId: messID, MemberId: memberID})
		auth(req, messID)
		_, err := core.LeaveMember(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodeFailedPrecondition {
			t.Fatalf("code = %v, want failed_precondition", got)
		}
	})

	t.Run("an unknown member is not found", func(t *testing.T) {
		req := connect.NewRequest(&corev1.LeaveMemberRequest{
			MessId: messID, MemberId: uuid.NewString(),
		})
		auth(req, messID)
		_, err := core.LeaveMember(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodeNotFound {
			t.Fatalf("code = %v, want not_found", got)
		}
	})

	t.Run("the manager cannot be removed this way", func(t *testing.T) {
		// Removing the sole manager would orphan the mess; that is account
		// deletion (Epic 13), not a member leave.
		var managerMembershipID string
		if err := owner.QueryRow(ctx,
			`SELECT id FROM memberships WHERE tenant_id = $1 AND role = 'MANAGER'`, messID).
			Scan(&managerMembershipID); err != nil {
			t.Fatalf("find manager membership: %v", err)
		}
		req := connect.NewRequest(&corev1.LeaveMemberRequest{
			MessId: messID, MemberId: managerMembershipID,
		})
		auth(req, messID)
		_, err := core.LeaveMember(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodeFailedPrecondition {
			t.Fatalf("code = %v, want failed_precondition", got)
		}
	})

	t.Run("a manager cannot leave another mess's member", func(t *testing.T) {
		// The two-tenant test the new query requires. A second mess, its own
		// manager and member; mess A's manager, scoped to A, must not be able
		// to reach B's member -- RLS makes it indistinguishable from absent.
		seedUser(ctx, t, owner, "aaaa0000-0000-0000-0000-0000000048b1", "dev-manager-b", "ম্যানেজার বি")

		createB := connect.NewRequest(&corev1.CreateMessRequest{
			Name: "অন্য মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
		})
		createB.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager-b")
		createdB, err := core.CreateMess(ctx, createB)
		if err != nil {
			t.Fatalf("CreateMess B: %v", err)
		}
		messB := createdB.Msg.GetMess().GetId()

		addB := connect.NewRequest(&corev1.AddMemberRequest{MessId: messB, DisplayName: "সজীব"})
		addB.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager-b")
		addB.Header().Set(transport.HeaderTenantID, messB)
		addedB, err := core.AddMember(ctx, addB)
		if err != nil {
			t.Fatalf("AddMember B: %v", err)
		}
		memberB := addedB.Msg.GetMember().GetId()

		// Mess A's manager, scoped to A, tries to remove B's member.
		req := connect.NewRequest(&corev1.LeaveMemberRequest{MemberId: memberB})
		auth(req, messID)
		_, err = core.LeaveMember(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodeNotFound {
			t.Fatalf("code = %v, want not_found (never leak that B's member exists)", got)
		}

		// And B's member is untouched.
		var leftAtB *time.Time
		if err := owner.QueryRow(ctx,
			`SELECT left_at FROM memberships WHERE id = $1`, memberB).Scan(&leftAtB); err != nil {
			t.Fatalf("read B membership: %v", err)
		}
		if leftAtB != nil {
			t.Error("B's member was marked left by A's manager — tenant isolation broke")
		}
	})
}
