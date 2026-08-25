.PHONY: help dev up down logs test verify lint property golden contract contract-live onboarding-live invariants \
        migrate migrate-down migrate-check sqlc proto tokens seed smoke load clean

API_DIR := services/api
PG_DSN  ?= postgres://tinbela:tinbela@localhost:5432/tinbela?sslmode=disable

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# ─────────────────────────── DEV ───────────────────────────

dev: up migrate seed ## Boot the full stack, migrate, seed
	@echo "✓ stack up — api on :8080, postgres on :5432"

up: ## Start containers
	docker compose up -d

down: ## Stop containers
	docker compose down

logs: ## Tail api logs
	docker compose logs -f api

clean: down ## Stop and remove volumes
	docker compose down -v

# ─────────────────────── CODE GENERATION ───────────────────

proto: ## Regenerate Go server, TS client, Dart models from proto/
	buf lint proto
	buf generate

sqlc: ## Regenerate internal/db from queries/*.sql
	cd $(API_DIR) && sqlc generate

tokens: ## Generate Dart theme, Tailwind config, CSS vars from tokens.json
	node packages/design-tokens/generate.mjs

# ──────────────────────── MIGRATIONS ───────────────────────

migrate: ## Apply all migrations
	migrate -path $(API_DIR)/migrations -database "$(PG_DSN)" up

migrate-down: ## Roll back one migration
	migrate -path $(API_DIR)/migrations -database "$(PG_DSN)" down 1

seed: ## Load demo mess fixture
	go run ./harness/fixtures/seed

# ───────────────────────── THE GATE ────────────────────────

verify: lint test property golden contract invariants migrate-check ## ★ Run every gate
	@echo ""
	@echo "  ✓ verify green"
	@echo ""

lint: ## Lint everything
	cd $(API_DIR) && golangci-lint run ./...
	@[ -d apps/manager/lib ] && cd apps/manager && flutter analyze || true
	@[ -d apps/web/app ] && cd apps/web && pnpm lint || true
	buf lint proto

test: ## Unit + integration tests
	cd $(API_DIR) && go test ./... -race -count=1

property: ## ★ The nine engine properties (Epic 02)
	cd $(API_DIR) && go test ./internal/meals ./internal/money \
		-run 'Property' -rapid.checks=1000 -count=1

golden: ## Shared vectors — Go now, Dart in P6
	cd $(API_DIR) && go test ./internal/... -run 'Golden' -count=1

contract: ## Proto compatibility + generated-client round trip
	@# `|| echo` here would mask a real breaking change as a skip. Skip only
	@# when the baseline genuinely does not exist.
	@if git rev-parse --verify --quiet master >/dev/null; then \
		buf breaking proto --against '.git#branch=master,subdir=proto'; \
	else \
		echo "  (no master branch — skipping breaking check)"; \
	fi
	cd $(API_DIR) && go test ./internal/transport -run 'Contract' -count=1
	@# The TypeScript half of the gate, against wire bytes captured from the
	@# running binary. Needs no stack, so it belongs in verify. The Dart half
	@# runs in CI's flutter job (`flutter test`), which is the only place a
	@# Flutter SDK is installed.
	cd packages/api-clients && pnpm test

contract-live: ## ★ Epic 03's gate — both generated clients against a REAL running binary
	@# The gate says "round-trip a real call against the running binary", and
	@# this is the literal reading of it: real socket, real Go process, real
	@# Postgres. It is not in `verify` because it needs Docker; it is one
	@# command so that "needs Docker" never becomes "nobody runs it".
	docker compose up -d
	@# Migrate BEFORE waiting on readiness. The api connects as tinbela_app,
	@# a role migration 000003 creates -- so on a fresh volume readyz can
	@# never go green until migrations have run, and waiting first deadlocks.
	$(MAKE) migrate
	go run ./harness/fixtures/seed
	@# Migrating can drop and recreate tables, which leaves the api's pooled
	@# connections holding cached statement plans for tables that no longer
	@# exist. Every call then fails until the process restarts. Restarting
	@# here is cheap; debugging it as "unauthenticated" is not.
	docker compose restart api
	@printf 'waiting for the api'
	@until curl -sf -o /dev/null http://localhost:8080/readyz; do printf '.'; sleep 1; done; echo ''
	cd packages/api-clients && pnpm test:live
	cd apps/manager && dart run tool/live_round_trip.dart
	@echo ""
	@echo "  ✓ Epic 03 gate: TypeScript and Dart both round-trip the running binary"

onboarding-live: ## Drive the app's own repositories against a running stack (08.1)
	@# Proves the layer the SCREENS depend on, not just the transport:
	@# config -> client -> repository -> domain type, in the order
	@# OnboardingFlow calls them. Creates a real mess, so it is never in verify.
	@#
	@# It leaves a pending membership (a member with no user account yet),
	@# which migration 000005 deliberately refuses to roll back. So
	@# `make verify` will fail its migrate-check afterwards until the dev
	@# database is reset:  make clean && make dev
	cd apps/manager && dart run tool/live_onboarding.dart

invariants: ## Grep-level guards that types cannot express
	@./harness/check-invariants.sh

migrate-check: ## Every migration applies and rolls back cleanly
	@./harness/migrate-roundtrip.sh

# ────────────────────────── HARNESS ────────────────────────

smoke: ## End-to-end scenario against a running env
	go run ./harness/smoke

load: ## Load test — 500 messes, 5k members
	k6 run harness/load/day-query.js
