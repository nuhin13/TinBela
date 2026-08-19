#!/usr/bin/env bash
# Grep-level guards for invariants that types cannot express.
# The highest-value 20 lines in the repository.
#
# Scans CODE only — never docs, never markdown. A doc that describes a rule
# is not a violation of it.
set -uo pipefail
FAIL=0
red()  { printf '  \033[31m✗\033[0m %s\n' "$1"; FAIL=1; }
green(){ printf '  \033[32m✓\033[0m %s\n' "$1"; }

echo "── invariants ──"

# 1. No float in a money path (Invariant 1)
HITS=$(grep -rn --include='*.go' -E '\bfloat(32|64)\b' \
        services/api/internal/money services/api/internal/meals 2>/dev/null \
        | grep -v '_test.go' || true)
[ -n "$HITS" ] && { red "float in a money path (Invariant 1)"; echo "$HITS" | head -5; } \
               || green "no float in money paths"

# 2. No UPDATE/DELETE on append-only tables (Invariant 2)
HITS=$(grep -rn --include='*.go' --include='*.sql' -iE \
        '(UPDATE|DELETE)[[:space:]]+(FROM[[:space:]]+)?(ledger_entries|meal_exceptions|period_statements)' \
        services/api/queries services/api/internal 2>/dev/null || true)
[ -n "$HITS" ] && { red "UPDATE/DELETE on an append-only table (Invariant 2)"; echo "$HITS" | head -5; } \
               || green "append-only respected"

# 3. No browser storage in the member PWA (code only, not docs)
HITS=$(grep -rn --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
        -E 'localStorage|sessionStorage' apps/web 2>/dev/null || true)
[ -n "$HITS" ] && { red "browser storage in the member PWA"; echo "$HITS" | head -5; } \
               || green "no browser storage in PWA"

# 4. No client-side money arithmetic in Flutter money widgets
if [ -d apps/manager/lib ]; then
  HITS=$(grep -rn --include='*.dart' -E '(paisa|amount|balance|rate)[A-Za-z]*\s*[-+*/]\s*' \
          apps/manager/lib 2>/dev/null | grep -v -E '\.g\.dart|// ignore: money-math' || true)
  [ -n "$HITS" ] && { red "client-side money arithmetic — render MathExplain instead"; echo "$HITS" | head -5; } \
                 || green "no client-side money arithmetic"
fi

# 5. Hardcoded strings in Flutter
[ -d apps/manager/lib ] && { ./harness/check-hardcoded-strings.sh apps/manager/lib || FAIL=1; }

# 6. Hardcoded colours in Flutter
[ -d apps/manager/lib ] && { ./harness/check-hardcoded-colors.sh apps/manager/lib || FAIL=1; }

# 7. Generated files not hand-edited
for f in apps/manager/lib/core/theme/tokens.g.dart packages/design-tokens/tokens.css; do
  if [ -f "$f" ] && ! head -3 "$f" | grep -qi "GENERATED"; then
    red "$f lost its GENERATED header — was it hand-edited?"
  fi
done
green "generated files intact"

echo ""
if [ $FAIL -eq 0 ]; then
  printf '  \033[32mall invariants hold\033[0m\n'
else
  printf '  \033[31mINVARIANT VIOLATION — fix before committing\033[0m\n'
fi
exit $FAIL
