package transport

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

type ctxKey int

const (
	ctxKeyRequestID ctxKey = iota
	ctxKeyCaller
	ctxKeyTenant
	ctxKeyTx
)

// Caller is the authenticated identity behind a request. Populated by the
// auth interceptor, never by a handler.
type Caller struct {
	UserID      uuid.UUID
	FirebaseUID string
	Locale      string // "bn" or "en"; drives error messages
}

// TenantScope is the mess a request is acting inside, resolved and
// authorised by the tenant interceptor.
type TenantScope struct {
	TenantID     uuid.UUID
	MembershipID uuid.UUID
	Role         string
}

func withRequestID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, ctxKeyRequestID, id)
}

// RequestID returns the id carried on this request. Every response and every
// log line carries it so a manager can quote one number to support.
func RequestID(ctx context.Context) string {
	id, _ := ctx.Value(ctxKeyRequestID).(string)
	return id
}

func withCaller(ctx context.Context, c Caller) context.Context {
	return context.WithValue(ctx, ctxKeyCaller, c)
}

// CallerFrom returns the authenticated identity. ok is false on the public
// endpoints, which run without an auth interceptor.
func CallerFrom(ctx context.Context) (Caller, bool) {
	c, ok := ctx.Value(ctxKeyCaller).(Caller)
	return c, ok
}

func withTenant(ctx context.Context, s TenantScope) context.Context {
	return context.WithValue(ctx, ctxKeyTenant, s)
}

// TenantFrom returns the authorised tenant scope for this request.
func TenantFrom(ctx context.Context) (TenantScope, bool) {
	s, ok := ctx.Value(ctxKeyTenant).(TenantScope)
	return s, ok
}

func withTx(ctx context.Context, tx pgx.Tx) context.Context {
	return context.WithValue(ctx, ctxKeyTx, tx)
}

// TxFrom returns the request's transaction.
//
// Handlers MUST use this rather than the pool. The RLS session variable is
// set with SET LOCAL, which is scoped to a transaction -- a query issued on
// any other connection runs with app.tenant_id unset and, because the
// policies compare against NULL, reads nothing at all.
func TxFrom(ctx context.Context) (pgx.Tx, bool) {
	tx, ok := ctx.Value(ctxKeyTx).(pgx.Tx)
	return tx, ok
}

// localeOf is the locale to phrase errors in, defaulting to Bangla.
func localeOf(ctx context.Context) string {
	if c, ok := CallerFrom(ctx); ok && c.Locale != "" {
		return c.Locale
	}
	return "bn"
}
