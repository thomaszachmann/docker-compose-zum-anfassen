#!/usr/bin/env bash
# Challenge Tag 5: Stack einmal mit falschem DB-Passwort starten, dann reparieren.
# Aufruf im Ordner ~/compose-lab/tag05 bei laufendem Stack.
set -u
POSTGRES_PASSWORD=lab-db-pw-456 docker compose up -d --wait
echo "Exit mit falschem Passwort: $?"
docker compose ps -a --format 'table {{.Service}}\t{{.Status}}'
docker compose logs --no-log-prefix migrate | tail -1 | grep -o 'password auth.*28P01)'
docker compose up -d --wait
echo "Exit nach Reparatur: $?"
docker compose ps -a --format 'table {{.Service}}\t{{.Status}}'
