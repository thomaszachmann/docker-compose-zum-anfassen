#!/usr/bin/env bash
# release.sh – Challenge Tag 8: Release mit Bake testen und bauen, ohne Build starten
# Aufruf: TAG=1.1 ./release.sh [projektordner]
set -euo pipefail
cd "${1:-$HOME/compose-lab/tag08}"
export TAG="${TAG:-1.1}"
docker buildx bake -f compose.yaml api-test        # Testlauf, bricht bei Rot ab
docker buildx bake -f compose.yaml api worker web  # Release-Images notes-*:$TAG
docker compose up -d --no-build --wait
echo "Version: $(curl -s "localhost:${API_PORT:-8080}/version")"
