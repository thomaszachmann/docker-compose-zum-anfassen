#!/usr/bin/env bash
# up.sh – legt das Arbeitsverzeichnis an und lädt die Basis-Images (idempotent)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/env.sh"

mkdir -p "$LAB"
echo "✔ Arbeitsverzeichnis $LAB"
for img in $LAB_IMAGES; do
  if docker image inspect "$img" >/dev/null 2>&1; then
    echo "✔ $img vorhanden"
  else
    docker pull -q "$img" >/dev/null
    echo "✔ $img geladen"
  fi
done
