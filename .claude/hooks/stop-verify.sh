#!/usr/bin/env bash
# Runs at the end of an agent turn. The turn is not clean until verify is green.
set -uo pipefail

# Already blocked once this turn — honour stop_hook_active or we loop forever.
INPUT=$(cat 2>/dev/null || true)
case "$INPUT" in *'"stop_hook_active":true'*) exit 0 ;; esac

if [ ! -f Makefile ]; then exit 0; fi

echo "── running make verify ──"
if make verify >/tmp/tinbela-verify.log 2>&1; then
  echo "✓ verify green"
  exit 0
else
  echo "✗ verify FAILED — the task is not done." >&2
  tail -40 /tmp/tinbela-verify.log >&2
  exit 2
fi
