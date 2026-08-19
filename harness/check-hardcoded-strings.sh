#!/usr/bin/env bash
# Fails when a user-visible string literal appears in a widget instead of an
# ARB key. Bangla is the default locale; every string must be translatable.
set -uo pipefail
DIR="${1:-apps/manager/lib}"
[ -d "$DIR" ] || exit 0

HITS=$(grep -rn --include='*.dart' -E "(Text|label|title|hintText)\s*:?\s*\(?['\"][^'\"]{3,}" "$DIR" \
  | grep -v -E "\.g\.dart|l10n|context\.l10n|AppLocalizations|// ignore: hardcoded" || true)

if [ -n "$HITS" ]; then
  printf '  \033[31m✗\033[0m hardcoded user-visible strings (use ARB keys):\n'
  echo "$HITS" | head -20
  exit 1
fi
printf '  \033[32m✓\033[0m no hardcoded strings\n'
