#!/usr/bin/env bash
# Runs the manager app against a local API (task 08.1).
#
# The only thing that varies between targets is how the app reaches the host
# machine, and getting it wrong looks like "the server is down":
#
#   android emulator  10.0.2.2      its alias for the host loopback
#   physical device   <LAN ip>      over wireless debugging, same wifi
#   chrome / desktop  localhost     same machine
#
# Usage: ./tool/run_dev.sh [flutter run args...]
set -euo pipefail
cd "$(dirname "$0")/.."

DEVICE="${DEVICE:-}"
[ -n "$DEVICE" ] || DEVICE="$(flutter devices --machine 2>/dev/null \
  | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)"

case "$DEVICE" in
  emulator-*|*android-arm*) HOST="10.0.2.2" ;;
  chrome|macos|linux|windows) HOST="localhost" ;;
  *)
    # A wireless device: its adb id is <ip>:<port>, and the app has to reach
    # this machine, not itself. Fall back to the LAN address.
    HOST="$(ipconfig getifaddr en0 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')"
    ;;
esac

API="${API_BASE_URL:-http://${HOST}:8080}"
echo "device=${DEVICE:-<default>}  api=${API}"

if ! curl -sf -o /dev/null -m 2 "${API}/readyz"; then
  echo "warning: ${API}/readyz did not answer — is \`make dev\` running?" >&2
fi

exec flutter run \
  --dart-define=FLAVOR=dev \
  --dart-define=API_BASE_URL="${API}" \
  "$@"
