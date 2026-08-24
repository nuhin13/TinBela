package transport

// Epic 04 task 04.7 -- role checks at the interceptor layer.

import (
	"context"

	"connectrpc.com/connect"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1/corev1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/meals/v1/mealsv1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/money/v1/moneyv1connect"
)

// memberReadable lists the tenant-scoped procedures a MEMBER may call.
//
// FAIL CLOSED: anything not on this list is manager-only. A denylist would
// mean that every RPC added later is member-writable until someone remembers
// to deny it, and the RPC most likely to be forgotten is the one that moves
// money. The cost of the choice is a permission_denied on the day a new
// member-facing call ships, which is a loud failure with an obvious fix.
//
// Membership of a mess is already proven by tenantInterceptor, under RLS.
// This is only the question of what the caller's role permits.
var memberReadable = map[string]bool{
	// Who else is in my mess.
	corev1connect.CoreServiceListMembersProcedure: true,
	// Today's headcount -- the screen the whole product exists for.
	mealsv1connect.MealsServiceGetDayProcedure: true,
	// The meal rate and every member's balance. Deliberately visible to
	// members: a mess where only the manager can see the maths is the
	// distrust TinBela exists to remove.
	moneyv1connect.MoneyServiceGetAccountsProcedure:  true,
	moneyv1connect.MoneyServiceGetStatementProcedure: true,
}

// roleInterceptor enforces MANAGER vs MEMBER before any handler runs.
//
// Doing it here rather than in each handler means a stubbed or newly added
// procedure is guarded from the moment it is mounted -- it cannot forget a
// check it never had. That matters right now: the money handlers are Epic 06
// stubs, and without this a MEMBER reaches AddLedgerEntry and is told
// "unimplemented", which is a promise that it will work later.
//
// It runs after tenantInterceptor, because the role it reads is the one that
// interceptor resolved from `memberships` under RLS. Ordering is load-bearing.
//
// CreateException and VoidException are manager-only here even though members
// will eventually mark their own meals off (Epic 05, and the member PWA in
// Epic 14). An interceptor sees a procedure, not a row, so it cannot express
// "your own meals only". Widening this without that ownership check in place
// would let any member edit any other member's meals -- so the widening
// belongs with the check, in Epic 05.
func roleInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			procedure := req.Spec().Procedure

			// Tenant-free procedures have no role to check: GetMe is how a
			// caller discovers its messes, CreateMess is how the first one
			// comes to exist.
			if tenantFreeProcedures[procedure] {
				return next(ctx, req)
			}

			scope, ok := TenantFrom(ctx)
			if !ok {
				// Unreachable behind tenantInterceptor. If it ever is
				// reachable, no role has been proven, so nothing is allowed.
				return nil, core.ErrNotMember
			}

			if scope.Role == roleManager || memberReadable[procedure] {
				return next(ctx, req)
			}
			return nil, core.ErrNotManager
		}
	}
}

// roleManager is the MANAGER role as stored in `memberships.role`.
const roleManager = "MANAGER"
