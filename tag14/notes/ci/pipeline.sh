#!/usr/bin/env bash
# pipeline.sh – die CI-Pipeline von notes, lokal wie im Runner (Tag 13)
# Aufruf: ci/pipeline.sh [projektname]   Standard: ci-<PID>, eindeutig pro Lauf
set -euo pipefail
cd "$(dirname "$0")/.."
P="${1:-ci-$$}"
dc() { docker compose -p "$P" -f compose.yaml -f compose.ci.yaml "$@"; }

# shellcheck disable=SC2329  # wird per trap aufgerufen
cleanup() {
  echo "--- Aufräumen: $P"
  dc down -v --remove-orphans >/dev/null 2>&1 || true
  docker image ls --format '{{.Repository}}:{{.Tag}}' | { grep "^$P-" || true; } \
    | xargs -r docker image rm >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Lab-Secrets, falls sie fehlen (frischer Checkout). Im echten Runner kommen
# die Werte aus dem Secret-Store der CI-Plattform, nie aus dem Repository.
lab_secret() { [ -s "secrets/$1" ] || printf '%s' "$2" > "secrets/$1"; }
mkdir -p secrets
lab_secret api_key.txt lab-api-key-123
lab_secret db_password.txt lab-db-pw-123
lab_secret db_url.txt postgres://notes:lab-db-pw-123@db:5432/notes
lab_secret grafana_admin.txt lab-grafana-pw-123
lab_secret npmrc "$(printf '%s\n' '@notes-lab:registry=https://npm.lab.invalid/' \
  '//npm.lab.invalid/:_authToken=lab-npm-token-123')"

echo "--- Lint: $P"
# Modell laden und prüfen: Probelauf, legt nichts an und zieht nichts
if ! out=$(dc --dry-run up -d --no-build --pull never 2>&1); then
  echo "$out"; exit 1
fi
echo "--- Unit-Tests"
dc --profile test build --quiet api-test
echo "--- Stack starten"
dc up -d --build --wait --wait-timeout 180 --quiet-pull --quiet-build
echo "--- Integrationstests"
rc=0
dc run --rm --quiet-pull tests || rc=$?
echo "--- Ergebnis: Exit $rc"
exit "$rc"
