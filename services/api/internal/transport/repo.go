package transport

import (
	"context"

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
		if err == pgx.ErrNoRows {
			return Caller{}, core.ErrNotFound
		}
		return Caller{}, core.ErrNotFound
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
		UserID:   userID,
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
