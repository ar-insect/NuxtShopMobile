#!/usr/bin/env sh
set -eu
API_BASE_URL="${API_BASE_URL:-http://localhost:4000}"
API_TOKEN="${API_TOKEN:-}"
flutter clean
flutter pub get
exec flutter build macos \
  --dart-define="API_BASE_URL=${API_BASE_URL}" \
  ${API_TOKEN:+--dart-define="API_TOKEN=${API_TOKEN}"} \
  "$@"
