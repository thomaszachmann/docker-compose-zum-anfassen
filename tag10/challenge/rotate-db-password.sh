#!/usr/bin/env bash
# rotate-db-password.sh – Challenge Tag 10: DB-Passwort in der richtigen Reihenfolge
# rotieren. Aufruf im Projektordner: ./rotate-db-password.sh <neues-passwort>
set -euo pipefail
NEW="${1:?Aufruf: $0 <neues-passwort>}"
case "$NEW" in
  *[!A-Za-z0-9._-]*) echo "✘ nur A-Z a-z 0-9 . _ - (das Passwort steht in einer URL)"
                     exit 2 ;;
esac
# 1. Rolle ändern, angemeldet mit dem alten Passwort aus secrets/db_password.txt.
#    Das SQL kommt über stdin: so steht das neue Passwort weder in ps noch in
#    docker inspect (Argumente) – nur in dieser Shell.
printf "ALTER ROLE notes PASSWORD '%s';\n" "$NEW" \
  | docker compose run --rm -T psql -q 2>/dev/null
echo "✔ Rolle notes geändert"
# 2. Secret-Dateien schreiben, ohne Zeilenumbruch
printf '%s' "$NEW" > secrets/db_password.txt
printf 'postgres://notes:%s@db:5432/notes' "$NEW" > secrets/db_url.txt
echo "✔ secrets/db_password.txt und secrets/db_url.txt aktualisiert"
# 3. Nur neu erzeugen, wer die DB-URL beim Start liest
docker compose up -d --force-recreate --no-build --wait api migrate 2>/dev/null
echo "✔ api und migrate neu erzeugt"
# 4. Gegenprobe über das Netz mit dem Passwort aus der Datei
if docker compose run --rm -T psql -Atc 'SELECT current_user' >/dev/null 2>&1; then
  echo "✔ Anmeldung mit neuem Passwort"
else
  echo "✘ Anmeldung scheitert"; exit 1
fi
