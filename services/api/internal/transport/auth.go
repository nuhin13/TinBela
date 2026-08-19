package transport

import (
	"context"
	"errors"
	"fmt"
	"os"
	"strings"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
)

// HeaderAuthorization carries the caller's bearer token.
const HeaderAuthorization = "Authorization"

// VerifiedToken is what a verifier proves about a caller.
type VerifiedToken struct {
	// FirebaseUID is the subject the token was issued for.
	FirebaseUID string
}

// TokenVerifier proves a bearer token belongs to a real identity.
//
// This is an interface so the transport layer can be built and tested with
// no Firebase project in existence. The real implementation lands with Epic
// 04 task 04.1, when there are credentials to verify against.
type TokenVerifier interface {
	Verify(ctx context.Context, token string) (VerifiedToken, error)
}

// devVerifier accepts tokens of the form "dev:<firebase-uid>" and proves
// nothing whatsoever.
//
// It exists so the transport gate -- a real client round-tripping a real
// call -- can be met before Firebase credentials do. NewDevVerifier refuses
// to construct outside APP_ENV=dev, so shipping it is a startup failure
// rather than a silent authentication bypass.
type devVerifier struct{}

// NewDevVerifier returns a verifier that trusts "dev:<uid>" tokens.
// It returns an error unless APP_ENV is exactly "dev".
func NewDevVerifier() (TokenVerifier, error) {
	if env := os.Getenv("APP_ENV"); env != "dev" {
		return nil, fmt.Errorf(
			"refusing to build the dev token verifier with APP_ENV=%q: it authenticates anyone", env)
	}
	return devVerifier{}, nil
}

func (devVerifier) Verify(_ context.Context, token string) (VerifiedToken, error) {
	uid, ok := strings.CutPrefix(token, "dev:")
	if !ok || uid == "" {
		return VerifiedToken{}, core.ErrInvalidToken
	}
	return VerifiedToken{FirebaseUID: uid}, nil
}

// UserLookup resolves a verified token subject to a TinBela user.
type UserLookup interface {
	ByFirebaseUID(ctx context.Context, firebaseUID string) (Caller, error)
}

// authInterceptor turns a bearer token into a Caller, and opens the
// transaction the whole request runs in.
//
// It rejects rather than passing an anonymous request through: every
// procedure mounted behind this interceptor requires an identity, and a
// handler that has to re-check would eventually forget to.
//
// The transaction is opened here, not in the tenant interceptor, because
// app.user_id must be set for every request -- including the tenant-free
// ones. SET LOCAL is transaction-scoped, so the scope and the unit of work
// have to be the same object. The tenant interceptor adds app.tenant_id to
// this same transaction when a procedure needs one.
func authInterceptor(pool *pgxpool.Pool, verifier TokenVerifier, users UserLookup) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			raw := req.Header().Get(HeaderAuthorization)
			token, ok := strings.CutPrefix(raw, "Bearer ")
			if !ok || strings.TrimSpace(token) == "" {
				return nil, core.ErrUnauthenticated
			}

			verified, err := verifier.Verify(ctx, strings.TrimSpace(token))
			if err != nil {
				// Any verifier failure is unauthenticated to the client.
				// Distinguishing "expired" from "forged" tells an attacker
				// which half of the problem they solved.
				if errors.Is(err, core.ErrInvalidToken) {
					return nil, core.ErrUnauthenticated
				}
				return nil, core.ErrUnauthenticated
			}

			caller, err := users.ByFirebaseUID(ctx, verified.FirebaseUID)
			if err != nil {
				// A valid token for someone with no TinBela account. This is
				// normal on first sign-in; CreateSession (Epic 04) is what
				// turns it into an account.
				return nil, core.ErrUnauthenticated
			}
			ctx = withCaller(ctx, caller)

			tx, err := pool.Begin(ctx)
			if err != nil {
				return nil, err
			}
			committed := false
			defer func() {
				if !committed {
					_ = tx.Rollback(context.WithoutCancel(ctx))
				}
			}()

			// Scopes every query below to this user's own rows (migration
			// 000004). Without it GetMe reads nothing at all.
			if _, err := tx.Exec(ctx,
				"SELECT set_config('app.user_id', $1, true)", caller.UserID.String()); err != nil {
				return nil, err
			}

			res, err := next(withTx(ctx, tx), req)
			if err != nil {
				return nil, err
			}
			if err := tx.Commit(ctx); err != nil {
				return nil, err
			}
			committed = true
			return res, nil
		}
	}
}
