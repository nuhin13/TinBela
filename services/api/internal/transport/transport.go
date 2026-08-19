package transport

import (
	"log/slog"
	"net/http"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/admin/v1/adminv1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1/corev1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/meals/v1/mealsv1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/money/v1/moneyv1connect"
)

// Deps is everything the transport layer needs from main.
type Deps struct {
	Pool        *pgxpool.Pool
	Logger      *slog.Logger
	Verifier    TokenVerifier
	RateLimiter *RateLimiter
	Timeout     time.Duration
	CORSOrigins []string
}

// Register mounts every Connect service on the mux.
//
// One binary serves gRPC, gRPC-Web and HTTP/JSON on the same paths (ADR-0002),
// so the Flutter app can speak plain JSON over HTTP (ADR-0003) while a
// generated TypeScript client speaks Connect, against identical handlers.
func Register(mux *http.ServeMux, d Deps) {
	if d.Timeout == 0 {
		d.Timeout = 15 * time.Second
	}
	if d.RateLimiter == nil {
		d.RateLimiter = NewRateLimiter(10, 30)
	}

	repo := NewRepo(d.Pool)

	// Order is outermost first.
	//
	//   recovery      a panic must not escape as a dropped connection
	//   requestID     so everything below can log and return the same id
	//   logging       sees the final code, because mapping happens inside
	//   rateLimit     cheap rejection before any database work
	//   timeout       bounds everything below it
	//   errorMapping  domain error -> Connect code + localised message;
	//                 outside auth so auth's own errors are mapped too
	//   auth          identity
	//   tenant        scope, transaction, RLS session variable
	common := []connect.Interceptor{
		recoveryInterceptor(d.Logger),
		requestIDInterceptor(),
		loggingInterceptor(d.Logger),
		rateLimitInterceptor(d.RateLimiter),
		timeoutInterceptor(d.Timeout),
		errorMappingInterceptor(d.Logger),
		authInterceptor(d.Pool, d.Verifier, repo),
	}

	scoped := connect.WithInterceptors(
		append(append([]connect.Interceptor{}, common...),
			tenantInterceptor(repo))...)

	// The admin surface reads across messes by definition, so it is mounted
	// without the tenant interceptor and carries its own authorisation
	// (Epic 16). Nothing here is a shortcut around tenant scope for the
	// member-facing services.
	unscoped := connect.WithInterceptors(common...)

	for _, h := range []struct {
		path    string
		handler http.Handler
	}{
		mount(corev1connect.NewCoreServiceHandler(coreService{pool: d.Pool}, scoped)),
		mount(mealsv1connect.NewMealsServiceHandler(mealsService{}, scoped)),
		mount(moneyv1connect.NewMoneyServiceHandler(moneyService{}, scoped)),
		mount(adminv1connect.NewAdminServiceHandler(adminService{}, unscoped)),
	} {
		mux.Handle(h.path, h.handler)
	}
}

func mount(path string, h http.Handler) struct {
	path    string
	handler http.Handler
} {
	return struct {
		path    string
		handler http.Handler
	}{path, h}
}

// CORS wraps the mux for browser clients (the member PWA and the admin
// portal). Origins are an allow-list, never "*": these requests carry a
// bearer token.
func CORS(next http.Handler, origins []string) http.Handler {
	allowed := make(map[string]bool, len(origins))
	for _, o := range origins {
		allowed[strings.TrimSpace(o)] = true
	}

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin != "" && allowed[origin] {
			h := w.Header()
			h.Set("Access-Control-Allow-Origin", origin)
			h.Set("Vary", "Origin")
			h.Set("Access-Control-Allow-Credentials", "true")
			h.Set("Access-Control-Allow-Headers", strings.Join([]string{
				"Content-Type", HeaderAuthorization, HeaderTenantID, HeaderRequestID,
				// Connect's own protocol headers.
				"Connect-Protocol-Version", "Connect-Timeout-Ms",
			}, ", "))
			h.Set("Access-Control-Expose-Headers", HeaderRequestID)
			h.Set("Access-Control-Max-Age", "86400")

			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}
