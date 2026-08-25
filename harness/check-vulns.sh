#!/usr/bin/env bash
# Task 18.4 -- Go dependency scanning.
#
# govulncheck reports only vulnerabilities your code can actually REACH, so a
# finding here is a call path, not an inventory entry. It has no suppression
# mechanism of its own, hence the allowlist: every accepted finding is written
# down with an owner and a reason, and anything unlisted fails.
set -uo pipefail
cd "$(dirname "$0")/.."

ALLOWLIST="harness/vuln-allowlist.txt"
API_DIR="services/api"

echo "-- go vulnerabilities --"

OUT=$(cd "$API_DIR" && go run golang.org/x/vuln/cmd/govulncheck@latest ./... 2>&1)
STATUS=$?

# Anything govulncheck could not even run is a failure, not a pass.
if [ $STATUS -ne 0 ] && ! grep -q '^Vulnerability #' <<<"$OUT"; then
  printf '  \033[31m✗\033[0m govulncheck did not complete\n'
  echo "$OUT" | tail -5
  exit 1
fi

FOUND=$(grep -oE '^Vulnerability #[0-9]+: (GO-[0-9]{4}-[0-9]+)' <<<"$OUT" \
        | grep -oE 'GO-[0-9]{4}-[0-9]+' | sort -u)

if [ -z "$FOUND" ]; then
  printf '  \033[32m✓\033[0m no reachable vulnerabilities\n'
  exit 0
fi

ALLOWED=$(grep -oE '^GO-[0-9]{4}-[0-9]+' "$ALLOWLIST" 2>/dev/null | sort -u)
NEW=$(comm -23 <(echo "$FOUND") <(echo "$ALLOWED"))

for id in $ALLOWED; do
  if grep -qx "$id" <<<"$FOUND"; then
    reason=$(grep -E "^$id" "$ALLOWLIST" | sed -E "s/^$id[[:space:]]+//")
    printf '  \033[33m!\033[0m %s allowed — %s\n' "$id" "$reason"
  else
    # The blocker cleared. Say so loudly: a stale entry is how the next real
    # finding gets waved through.
    printf '  \033[33m!\033[0m %s is allowlisted but no longer reported — remove it\n' "$id"
  fi
done

if [ -n "$NEW" ]; then
  printf '  \033[31m✗\033[0m new reachable vulnerabilities:\n'
  for id in $NEW; do
    printf '      %s\n' "$id"
    grep -A3 "$id" <<<"$OUT" | sed 's/^/        /' | head -4
  done
  exit 1
fi

printf '  \033[32m✓\033[0m no unaccounted vulnerabilities\n'
