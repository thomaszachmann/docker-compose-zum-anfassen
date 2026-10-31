#!/usr/bin/env bash
# audit.sh – Challenge Tag 9: Härtung der laufenden Container eines Projekts prüfen
# Aufruf: ./audit.sh [projekt]   (Standard: notes). Exit-Code = Zahl der ✘.
# Sieht von innen nach: ein Hilfscontainer teilt den PID-Namespace des Ziels und
# liest /proc/1 – das klappt auch bei scratch-Images ohne Shell.
set -uo pipefail
P="${1:-notes}"
fail=0
check() {
  if [ "$2" = "$3" ]; then echo "  ✔ $1"
  else echo "  ✘ $1 ($2)"; fail=$((fail + 1)); fi
}
# Läuft im Hilfscontainer; \$ bleibt für dessen Shell stehen
# shellcheck disable=SC2016
probe='ro=$(awk "\$5==\"/\" {split(\$6, o, \",\"); print o[1]}" /proc/1/mountinfo)
  nnp=$(awk "/^NoNewPrivs/ {print \$2}" /proc/1/status)
  cap=$(awk "/^CapBnd/ {print \$2}" /proc/1/status)
  echo "$ro $nnp $cap"'
for id in $(docker ps -q --filter "label=com.docker.compose.project=$P"); do
  docker ps --filter "id=$id" --format '{{.Names}}'
  read -r ro nnp cap < <(docker run --rm --label "lab=${LAB_LABEL:-compose-lab}" \
    --pid "container:$id" alpine:3.24 sh -c "$probe")
  check "Dateisystem read-only" "$ro" ro
  check "no-new-privileges" "$nnp" 1
  check "keine Capabilities" "$cap" 0000000000000000
  limit=$(docker stats --no-stream --format '{{.MemUsage}}' "$id" | awk '{print $3}')
  case "$limit" in
    *MiB | *KiB) check "Speicherlimit unter 1 GiB" ja ja ;;
    *) check "Speicherlimit unter 1 GiB" "$limit" ja ;;
  esac
done
echo "Befunde: $fail"
exit "$fail"
