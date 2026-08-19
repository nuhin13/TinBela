// Command api is the TinBela backend: one Go binary, modular monolith
// (ADR-0001), serving Connect over HTTP/JSON and gRPC (ADR-0002).
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/transport"
)

const version = "0.0.0-epic03"

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	if err := run(logger); err != nil {
		logger.Error("fatal", "err", err)
		os.Exit(1)
	}
}

func run(logger *slog.Logger) error {
	// All date boundaries resolve in Asia/Dhaka, server-side (Invariant 5).
	if _, err := time.LoadLocation("Asia/Dhaka"); err != nil {
		return err
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	dsn := os.Getenv("PG_DSN")
	if dsn == "" {
		return errors.New("PG_DSN is required")
	}
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return err
	}
	defer pool.Close()

	verifier, err := buildVerifier()
	if err != nil {
		return err
	}

	mux := http.NewServeMux()
	registerOps(mux, pool)
	transport.Register(mux, transport.Deps{
		Pool:        pool,
		Logger:      logger,
		Verifier:    verifier,
		RateLimiter: transport.NewRateLimiter(10, 30),
		Timeout:     15 * time.Second,
	})

	port := os.Getenv("HTTP_PORT")
	if port == "" {
		port = "8080"
	}

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           transport.CORS(mux, corsOrigins()),
		ReadHeaderTimeout: 10 * time.Second,
	}

	go func() {
		<-ctx.Done()
		shutdown, cancel := context.WithTimeout(context.Background(), 15*time.Second)
		defer cancel()
		_ = srv.Shutdown(shutdown)
	}()

	logger.Info("tinbela api starting",
		"port", port, "tz", "Asia/Dhaka", "version", version)
	if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	logger.Info("tinbela api stopped")
	return nil
}

// buildVerifier picks how bearer tokens are proven.
//
// Firebase verification is Epic 04 task 04.1. Until it exists, dev builds
// use a verifier that trusts "dev:<uid>" -- and NewDevVerifier refuses to
// construct unless APP_ENV=dev, so a non-dev deployment fails at startup
// rather than accepting anyone.
func buildVerifier() (transport.TokenVerifier, error) {
	return transport.NewDevVerifier()
}

func corsOrigins() []string {
	raw := os.Getenv("CORS_ORIGINS")
	if raw == "" {
		return nil
	}
	return strings.Split(raw, ",")
}

// registerOps mounts the operational endpoints. They sit outside the Connect
// interceptor chain on purpose: a health check that needs authentication,
// rate-limit budget, or a tenant is not a health check.
func registerOps(mux *http.ServeMux, pool *pgxpool.Pool) {
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, `{"status":"ok"}`)
	})

	// Readiness answers "should traffic come here", so it checks the thing
	// that makes the answer no.
	mux.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()
		if err := pool.Ping(ctx); err != nil {
			writeJSON(w, http.StatusServiceUnavailable, `{"status":"database unreachable"}`)
			return
		}
		writeJSON(w, http.StatusOK, `{"status":"ready"}`)
	})

	mux.HandleFunc("/version", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, `{"version":"`+version+`"}`)
	})
}

func writeJSON(w http.ResponseWriter, status int, body string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_, _ = w.Write([]byte(body))
}
