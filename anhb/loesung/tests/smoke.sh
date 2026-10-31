#!/bin/sh
# smoke.sh – Rauchtest im CI-Netz, Ausgabe ✔/✘, Exit-Code = Zahl der Fehler
fail=0
check() {
  if [ "$2" = "$3" ]; then echo "✔ $1"; else echo "✘ $1 ($2)"; fail=$((fail + 1)); fi
}
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
check "api healthz" "$(curl -s http://api:8080/healthz)" ok
check "web healthz" "$(code http://web:3000/healthz)" 200
check "POST ohne Key" "$(code -X POST -H 'Content-Type: application/json' \
  -d '{"text":"ci"}' http://api:8080/notes)" 401
check "POST über web" "$(code -X POST -H 'Content-Type: application/json' \
  -d '{"text":"ci"}' http://web:3000/api/notes)" 201
exit "$fail"
