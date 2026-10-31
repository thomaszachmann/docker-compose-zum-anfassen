#!/usr/bin/env bash
# ci.sh – Pipeline lokal: eigener Projektname, Aufräumen per trap, Exit-Code der Tests
set -euo pipefail
cd "$(dirname "$0")"
P="ci-$$"
dc() { docker compose -p "$P" -f compose.yaml -f compose.ci.yaml "$@"; }
cleanup() {
  dc down -v --remove-orphans >/dev/null 2>&1 || true
  docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^$P-" \
    | xargs -r docker rmi >/dev/null 2>&1 || true
}
trap cleanup EXIT
dc up -d --build --wait --quiet-pull >/dev/null 2>&1
dc run --rm tests
