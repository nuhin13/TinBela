#!/usr/bin/env bash
# Fails when a colour literal appears instead of a generated token.
set -uo pipefail
DIR="${1:-apps/manager/lib}"
[ -d "$DIR" ] || exit 0

HITS=$(grep -rn --include='*.dart' -E "Color\(0x|\bColors\.[a-z]" "$DIR" \
  | grep -v -E "tokens\.g\.dart|// ignore: hardcoded" || true)

if [ -n "$HITS" ]; then
  printf '  \033[31m✗\033[0m hardcoded colours (use TinBelaColors from tokens.g.dart):\n'
  echo "$HITS" | head -20
  exit 1
fi
printf '  \033[32m✓\033[0m no hardcoded colours\n'
