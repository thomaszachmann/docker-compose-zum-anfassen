#!/usr/bin/env bash
# check.sh – prüft das Trainingsgelände (✔/✘). Exit-Code = Anzahl Fehler.
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/env.sh"
fail=0
ok()  { echo "✔ $1"; }
bad() { echo "✘ $1"; fail=$((fail + 1)); }
t()   { if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

t "Docker läuft" "docker info"
t "Compose v2 vorhanden (docker compose)" "docker compose version"
t "buildx vorhanden" "docker buildx version"
t "curl und jq im PATH" "command -v curl && command -v jq"
missing=""
for img in $LAB_IMAGES; do
  docker image inspect "$img" >/dev/null 2>&1 || missing="$missing $img"
done
if [ -z "$missing" ]; then ok "Basis-Images vorhanden"; else
  bad "Basis-Images fehlen (sonst: up.sh):$missing"; fi
t "Demo-Anwendung unter $NOTES" "test -f $NOTES/notes-api/main.go"
t "mindestens 5 GB frei auf dem Mac" \
  "df -k \"\$HOME\" | awk 'NR==2 { exit !(\$4 >= 5 * 1024 * 1024) }'"
exit "$fail"
