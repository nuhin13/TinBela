package transport

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
	"github.com/droidbuilder/tinbela/services/api/internal/db"
)

// repo implements the lookups the interceptors need, on top of the sqlc
// queries. It is the boundary where a pgx error stops being a pgx error:
// nothing above this returns a driver string (docs/eng/errors.md).
type repo struct {
	pool *pgxpool.Pool
}

// NewRepo builds the interceptor lookups.
func NewRepo(pool *pgxpool.Pool) interface {
	UserLookup
	MembershipLookup
} {
	return repo{pool: pool}
}

// ByFirebaseUID runs on the pool, not a request transaction: it happens
// before any tenant is known, and `users` carries no RLS policy for exactly
// that reason.
func (r repo) ByFirebaseUID(ctx context.Context, firebaseUID string) (Caller, error) {
	u, err := db.New(r.pool).GetUserByFirebaseUID(ctx, &firebaseUID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// No account yet. Normal on first sign-in.
			return Caller{}, core.ErrNotFound
		}
		// Anything else is a database fault, and it must NOT be reported as
		// "no such user". Doing so tells the caller "sign in again" for a
		// problem no amount of signing in can fix, and hides the fault
		// entirely: authInterceptor turns ErrNotFound into unauthenticated
		// without logging a cause.
		//
		// This is not hypothetical. After `migrate` down/up recreates the
		// tables, pooled connections hold cached statement plans for the old
		// ones; every call then failed as `unauthenticated` until the process
		// was restarted, with nothing in the logs to say why.
		//
		// Wrapping instead lets errorMappingInterceptor map it to `internal`
		// AND log the original cause -- which is the only place the cause
		// survives. The client still never sees a pgx error.
		return Caller{}, fmt.Errorf("look up user by firebase uid: %w", err)
	}
	return Caller{
		UserID:      u.ID,
		FirebaseUID: firebaseUID,
		Locale:      u.Locale,
	}, nil
}

// MembershipFor runs on the request transaction, after SET LOCAL
// app.tenant_id. RLS is what makes this authoritative: a caller outside the
// mess does not get a rejected row, they get no row.
func (r repo) MembershipFor(ctx context.Context, tx pgx.Tx, userID, tenantID uuid.UUID) (TenantScope, error) {
	m, err := db.New(tx).GetMembershipForUserInTenant(ctx, db.GetMembershipForUserInTenantParams{
		UserID:   pgUUID(userID),
		TenantID: tenantID,
	})
	if err != nil {
		return TenantScope{}, core.ErrTenantMismatch
	}
	return TenantScope{
		TenantID:     m.TenantID,
		MembershipID: m.ID,
		Role:         m.Role,
	}, nil
}
