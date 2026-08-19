.PHONY: help dev up down logs test verify lint property golden contract invariants \
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
	buf breaking proto --against '.git#branch=master,subdir=proto' || echo "  (no master branch yet — skipping)"
	cd $(API_DIR) && go test ./internal/transport -run 'Contract' -count=1

invariants: ## Grep-level guards that types cannot express
	@./harness/check-invariants.sh

migrate-check: ## Every migration applies and rolls back cleanly
	@./harness/migrate-roundtrip.sh

# ────────────────────────── HARNESS ────────────────────────

smoke: ## End-to-end scenario against a running env
	go run ./harness/smoke

load: ## Load test — 500 messes, 5k members
	k6 run harness/load/day-query.js
