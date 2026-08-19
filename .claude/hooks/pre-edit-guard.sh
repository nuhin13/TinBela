#!/usr/bin/env bash
# Blocks edits to hand-owned and generated paths.
# Exit 2 = block the tool call and tell the agent why.
set -uo pipefail

FILE="${CLAUDE_TOOL_FILE_PATH:-}"
[ -z "$FILE" ] && exit 0

block() {
  echo "BLOCKED: $1" >&2
  echo "Reason: $2" >&2
  exit 2
}

case "$FILE" in
  *services/api/internal/db/*)
    block "$FILE" "sqlc-generated. Edit services/api/queries/*.sql then run 'make sqlc'." ;;
  *services/api/internal/meals/engine.go)
    block "$FILE" "Hand-owned domain engine (Epic 02). The founder writes this. You may scaffold tests only." ;;
  *services/api/internal/money/settle.go)
    block "$FILE" "Hand-owned settlement engine (Epic 02). The founder writes this. You may scaffold tests only." ;;
  *services/api/testdata/vectors/*)
    block "$FILE" "Golden vectors are hand-owned. Propose additions as a diff for human approval." ;;
  */packages/api-clients/gen/*)
    block "$FILE" "Generated from proto. Edit the .proto and run 'make proto'." ;;
  *.env|*/secrets/*)
    block "$FILE" "Secrets are never edited by an agent." ;;
esac

exit 0
