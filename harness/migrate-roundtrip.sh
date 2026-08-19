#!/usr/bin/env bash
# Proves every migration applies cleanly and rolls back cleanly.
# A migration without a working .down.sql is a trap you set for yourself.
set -euo pipefail

DSN="${PG_DSN:-postgres://tinbela:tinbela@localhost:5432/tinbela?sslmode=disable}"
DIR="services/api/migrations"

command -v migrate >/dev/null || { echo "  (migrate not installed — skipping)"; exit 0; }
pg_isready -q 2>/dev/null || { echo "  (postgres not running — skipping)"; exit 0; }

echo "── migrate round trip ──"
migrate -path "$DIR" -database "$DSN" up
migrate -path "$DIR" -database "$DSN" down -all
migrate -path "$DIR" -database "$DSN" up
printf '  \033[32m✓\033[0m migrations round trip cleanly\n'
