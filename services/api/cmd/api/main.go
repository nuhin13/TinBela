// Command api is the TinBela backend: one Go binary, modular monolith
// (ADR-0001), serving Connect over HTTP/JSON and gRPC (ADR-0002).
package main

import (
	"log/slog"
	"net/http"
	"os"
	"time"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	// All date boundaries resolve in Asia/Dhaka, server-side (Invariant 5).
	if _, err := time.LoadLocation("Asia/Dhaka"); err != nil {
		logger.Error("Asia/Dhaka timezone unavailable", "err", err)
		os.Exit(1)
	}

	port := os.Getenv("HTTP_PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})
	mux.HandleFunc("/readyz", func(w http.ResponseWriter, _ *http.Request) {
		// TODO(Epic 03 task 03.11): check the database pool.
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ready"}`))
	})
	mux.HandleFunc("/version", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"version":"0.0.0-epic00"}`))
	})

	// TODO(Epic 03): mount Connect handlers + interceptors here.
	//   transport.Register(mux, deps)

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 10 * time.Second,
	}

	logger.Info("tinbela api starting", "port", port, "tz", "Asia/Dhaka")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		logger.Error("server failed", "err", err)
		os.Exit(1)
	}
}
