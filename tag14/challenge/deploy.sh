#!/usr/bin/env bash
# deploy.sh – Challenge Tag 14: bauen, übertragen, deployen, bei Fehler zurück
# Aufruf im Projektordner: ./deploy.sh <tag>   (CTX, WAIT_TIMEOUT überschreibbar)
set -euo pipefail
cd "$(dirname "$0")"
neu="${1:?Aufruf: ./deploy.sh <tag>}"
ctx="${CTX:-notes-server}"
p="${COMPOSE_PROJECT_NAME:-notes}"
remote() { docker --context "$ctx" compose -f compose.yaml -f compose.prod.yaml "$@"; }

# Welche Version läuft? Das Tag des api-Images (leer beim ersten Deploy)
alt="$(remote ps --format json api | jq -r '.Image | split(":")[1]' || true)"
echo "Server: ${alt:-nichts}  →  Ziel: $neu"

TAG="$neu" docker compose build --quiet api worker web
docker save "$p-api:$neu" "$p-worker:$neu" "$p-web:$neu" | docker --context "$ctx" load

if TAG="$neu" remote up -d --no-build --wait --wait-timeout "${WAIT_TIMEOUT:-120}"; then
  echo "✔ $neu läuft"
  exit 0
fi
echo "✘ $neu nicht gesund"
[ -n "$alt" ] || exit 1
TAG="$alt" remote up -d --no-build --wait
echo "↩ zurück auf $alt"
exit 1
