#!/bin/sh
# integration.sh – Integrationstests gegen den laufenden Stack (Tag 13)
# Läuft im Dienst tests (curlimages/curl). Exit-Code = Zahl der Fehler.
API_URL=${API_URL:-http://api:8080}
WEB_URL=${WEB_URL:-http://web:3000}
KEY=$(cat "${NOTES_API_KEY_FILE:-/run/secrets/api_key}") || exit 1
TEXT="ci-$(date +%s)-$$"
JSON='Content-Type: application/json'
fail=0

ok()  { echo "✔ $1"; }
bad() { echo "✘ $1"; fail=$((fail + 1)); }
# status <methode> <url> [curl-optionen…] – gibt nur den HTTP-Status aus
status() {
  m=$1 u=$2; shift 2
  curl -s -o /dev/null -w '%{http_code}' -X "$m" "$@" "$u"
}
# expect <name> <ist> <soll>
expect() {
  if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (erwartet $3, bekommen $2)"; fi
}

expect "api /healthz" "$(status GET "$API_URL/healthz")" 200
expect "web /healthz" "$(status GET "$WEB_URL/healthz")" 200
expect "POST ohne Key → 401" \
  "$(status POST "$API_URL/notes" -H "$JSON" -d '{"text":"x"}')" 401
expect "POST mit Key → 201" "$(status POST "$API_URL/notes" -H "$JSON" \
  -H "X-API-Key: $KEY" -d "{\"text\":\"$TEXT\"}")" 201
if curl -s "$API_URL/notes" | grep -q "$TEXT"; then
  ok "GET /notes enthält die Notiz"
else
  bad "GET /notes enthält die Notiz nicht"
fi
expect "POST über web → 201" \
  "$(status POST "$WEB_URL/api/notes" -H "$JSON" -d '{"text":"via web"}')" 201
if curl -s "$API_URL/metrics" | grep -q '^notes_created_total [1-9]'; then
  ok "/metrics zählt notes_created_total"
else
  bad "/metrics ohne notes_created_total > 0"
fi
echo "Fehler: $fail"
exit "$fail"
