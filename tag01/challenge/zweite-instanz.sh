#!/usr/bin/env bash
# zweite-instanz.sh – Challenge Tag 1: dieselbe compose.yaml als zweites Projekt
# (notes2) auf anderen Ports starten, prüfen und samt Images wieder entfernen.
# Aufruf im Ordner ~/compose-lab/tag01: bash ../code/tag01/challenge/zweite-instanz.sh
set -euo pipefail
export API_PORT=8081 WEB_PORT=3001
docker compose -p notes2 up -d
sleep 3
docker compose ls
curl -s -X POST localhost:3001/api/notes -H 'Content-Type: application/json' \
  -d '{"text":"nur in notes2"}'; echo
curl -s localhost:8081/notes; echo
curl -s localhost:8080/notes; echo
docker compose -p notes2 down --rmi local
