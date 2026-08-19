package transport

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"runtime/debug"
	"time"

	"connectrpc.com/connect"
	"github.com/google/uuid"
)

// HeaderRequestID is echoed on every response, success or failure.
const HeaderRequestID = "X-Request-Id"

// requestIDInterceptor assigns an id and puts it on the context, the
// response headers, and -- when the call fails -- the error metadata, so a
// client can quote it whichever way the call ended.
func requestIDInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			id := req.Header().Get(HeaderRequestID)
			if id == "" {
				id = uuid.NewString()
			}
			ctx = withRequestID(ctx, id)

			res, err := next(ctx, req)
			if err != nil {
				var ce *connect.Error
				if !errors.As(err, &ce) {
					ce = connect.NewError(connect.CodeInternal, err)
				}
				ce.Meta().Set(HeaderRequestID, id)
				return nil, ce
			}
			res.Header().Set(HeaderRequestID, id)
			return res, nil
		}
	}
}

// loggingInterceptor emits one structured line per call. Nothing here logs a
// request body: meal patterns and ledger notes are member data, and a log
// aggregator is a wider audience than the mess.
func loggingInterceptor(logger *slog.Logger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			start := time.Now()
			res, err := next(ctx, req)

			attrs := []any{
				"procedure", req.Spec().Procedure,
				"request_id", RequestID(ctx),
				"ms", time.Since(start).Milliseconds(),
			}
			if c, ok := CallerFrom(ctx); ok {
				attrs = append(attrs, "user_id", c.UserID)
			}
			if s, ok := TenantFrom(ctx); ok {
				attrs = append(attrs, "tenant_id", s.TenantID)
			}

			if err != nil {
				// This logs the error as the client will see it. The
				// original cause is logged by errorMappingInterceptor,
				// which is the only layer that still holds it.
				attrs = append(attrs, "code", connect.CodeOf(err).String(), "err", err.Error())
				logger.LogAttrs(ctx, slog.LevelWarn, "rpc failed", slog.Any("f", attrs))
				return nil, err
			}
			logger.LogAttrs(ctx, slog.LevelInfo, "rpc", slog.Any("f", attrs))
			return res, nil
		}
	}
}

// recoveryInterceptor turns a panic into an internal error instead of taking
// the process down. The stack reaches the log, never the client.
func recoveryInterceptor(logger *slog.Logger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (res connect.AnyResponse, err error) {
			defer func() {
				if p := recover(); p != nil {
					logger.Error("panic in handler",
						"procedure", req.Spec().Procedure,
						"request_id", RequestID(ctx),
						"panic", fmt.Sprint(p),
						"stack", string(debug.Stack()))
					err = connect.NewError(connect.CodeInternal, errors.New("internal error"))
				}
			}()
			return next(ctx, req)
		}
	}
}

// timeoutInterceptor caps how long any single call may run.
//
// It only ever shortens: a client that asked for less keeps its own deadline,
// which matters on a phone where the user has already walked away.
func timeoutInterceptor(d time.Duration) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			if deadline, ok := ctx.Deadline(); ok && time.Until(deadline) < d {
				return next(ctx, req)
			}
			ctx, cancel := context.WithTimeout(ctx, d)
			defer cancel()
			return next(ctx, req)
		}
	}
}

// errorMappingInterceptor is the outermost domain-aware layer: it converts a
// domain error value into the Connect code and localised message from
// docs/eng/errors.md. Handlers return core.ErrX and never build a
// connect.Error themselves.
//
// It logs the ORIGINAL error for anything that maps to `internal`. That is
// the whole point of doing it here: an unmapped error is by definition one
// nobody phrased for a user, so the client gets "internal error" and the
// cause survives only if this layer writes it down. Every interceptor
// outside this one sees the mapped error and nothing else.
func errorMappingInterceptor(logger *slog.Logger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			res, err := next(ctx, req)
			if err == nil {
				return res, nil
			}
			mapped := toConnect(err, localeOf(ctx))
			if mapped.Code() == connect.CodeInternal {
				logger.Error("unmapped error",
					"procedure", req.Spec().Procedure,
					"request_id", RequestID(ctx),
					"cause", err.Error())
			}
			return nil, mapped
		}
	}
}
