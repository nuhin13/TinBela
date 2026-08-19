package transport

import (
	"context"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
)

// HeaderTenantID names the mess a request acts inside.
const HeaderTenantID = "X-Tenant-Id"

// MembershipLookup answers whether a caller belongs to a mess. It is handed
// the request transaction, so RLS is already in force for its query.
type MembershipLookup interface {
	MembershipFor(ctx context.Context, tx pgx.Tx, userID, tenantID uuid.UUID) (TenantScope, error)
}

// tenantInterceptor resolves the mess, opens the request's transaction, sets
// the RLS session variable, and authorises the caller -- in that order,
// which is the whole point.
//
// The authorisation check is a SELECT against `memberships` issued AFTER
// `SET LOCAL app.tenant_id`. So the check runs under the same policy that
// guards every other query: if the caller is not in that mess, the row is
// not merely rejected, it is invisible. There is no hand-written
// `if requested != caller.tenant` to forget, and no path where a handler
// runs with the variable unset -- an unset variable makes the policies
// compare against NULL and read nothing at all.
//
// Cross-tenant access returns ErrTenantMismatch, which docs/eng/errors.md
// maps to a generic not-found. Confirming another mess exists is a leak.
//
// The transaction is the unit of work. SET LOCAL is transaction-scoped, so a
// query issued on any other connection would run unscoped; TxFrom is how
// handlers get the right one.
// tenantFreeProcedures are mounted behind auth but not behind tenant scope.
// GetMe is how a client discovers which messes it has, so requiring one
// would be circular; CreateMess brings a mess into existence.
var tenantFreeProcedures = map[string]bool{
	"/tinbela.core.v1.CoreService/GetMe":      true,
	"/tinbela.core.v1.CoreService/CreateMess": true,
}

func tenantInterceptor(members MembershipLookup) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			if tenantFreeProcedures[req.Spec().Procedure] {
				return next(ctx, req)
			}

			caller, ok := CallerFrom(ctx)
			if !ok {
				return nil, core.ErrUnauthenticated
			}

			raw := req.Header().Get(HeaderTenantID)
			if raw == "" {
				return nil, core.ErrNotMember
			}
			tenantID, err := uuid.Parse(raw)
			if err != nil {
				// An unparseable tenant id is indistinguishable from one
				// that belongs to someone else.
				return nil, core.ErrTenantMismatch
			}

			// The transaction was opened by the auth interceptor, which
			// already set app.user_id on it.
			tx, ok := TxFrom(ctx)
			if !ok {
				return nil, core.ErrUnauthenticated
			}

			// Scope first. Everything after this line, including the
			// authorisation check below, is filtered by Postgres.
			if _, err := tx.Exec(ctx,
				"SELECT set_config('app.tenant_id', $1, true)", tenantID.String()); err != nil {
				return nil, err
			}

			scope, err := members.MembershipFor(ctx, tx, caller.UserID, tenantID)
			if err != nil {
				return nil, core.ErrTenantMismatch
			}

			return next(withTenant(ctx, scope), req)
		}
	}
}
