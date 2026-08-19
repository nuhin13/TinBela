#!/usr/bin/env bash
# Formats and lints immediately after an edit, per file type.
set -uo pipefail

FILE="${CLAUDE_TOOL_FILE_PATH:-}"
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

case "$FILE" in
  *.go)
    command -v gofmt >/dev/null && gofmt -w "$FILE"
    command -v go    >/dev/null && (cd services/api && go vet ./... 2>&1 | head -20) || true
    ;;
  *.dart)
    command -v dart >/dev/null && dart format "$FILE" >/dev/null 2>&1 || true
    ;;
  *.proto)
    command -v buf >/dev/null && { buf lint || echo "buf lint failed" >&2; }
    ;;
  *.ts|*.tsx|*.mjs|*.json)
    command -v pnpm >/dev/null && pnpm -s prettier --write "$FILE" >/dev/null 2>&1 || true
    ;;
  *.sh)
    chmod +x "$FILE"
    ;;
esac

exit 0
