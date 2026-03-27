#!/usr/bin/env sh
set -eu

# Defaults (override by exporting env vars before running)
API_BASE_URL="${API_BASE_URL:-http://localhost:4000}"
API_TOKEN="${API_TOKEN:-}"

# Pass through extra cli args to flutter (e.g., --release)
exec flutter run -d chrome \
  --dart-define="API_BASE_URL=${API_BASE_URL}" \
  ${API_TOKEN:+--dart-define="API_TOKEN=${API_TOKEN}"} \
  "$@"
