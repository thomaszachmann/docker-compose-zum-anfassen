#!/usr/bin/env bash
# clean.sh [--all] – räumt nur Lab-Spuren auf:
#   Container und Netze des Compose-Projekts $PROJECT oder mit Label lab=$LAB_LABEL,
#   selbst gebaute Images $PROJECT-*.
#   --all  zusätzlich Volumes (Datenbank!) und die Basis-Images aus up.sh.
# Nie docker system prune oder volume prune: Das träfe auch fremde Projekte.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/env.sh"
sel=(--filter "label=com.docker.compose.project=$PROJECT")
own=(--filter "label=lab=$LAB_LABEL")

# rm_ids <was> <befehl…> – liest IDs/Namen von stdin, entfernt sie einzeln, zählt
rm_ids() {
  local what=$1 n=0 id
  shift
  while read -r id; do
    [ -n "$id" ] || continue
    if "$@" "$id" >/dev/null 2>&1; then n=$((n + 1)); fi
  done
  echo "✔ $what entfernt: $n"
}

{ docker ps -aq "${sel[@]}"; docker ps -aq "${own[@]}"; } | sort -u \
  | rm_ids Container docker rm -f
{ docker network ls -q "${sel[@]}"; docker network ls -q "${own[@]}"; } | sort -u \
  | rm_ids Netze docker network rm
docker image ls --format '{{.Repository}}:{{.Tag}}' | { grep -E "^$PROJECT-" || true; } \
  | rm_ids Images docker rmi

if [ "${1:-}" = --all ]; then
  { docker volume ls -q "${sel[@]}"; docker volume ls -q "${own[@]}"; } | sort -u \
    | rm_ids Volumes docker volume rm
  for img in $LAB_IMAGES; do echo "$img"; done | rm_ids Basis-Images docker rmi
fi
