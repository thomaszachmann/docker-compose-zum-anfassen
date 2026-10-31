# env.sh – zum source'n: Variablen des Trainingsgeländes
# Für Tests überschreibbar: LAB, LAB_LABEL, COMPOSE_PROJECT_NAME
export LAB="${LAB:-$HOME/compose-lab}"
export NOTES="$LAB/notes"
export LAB_LABEL="${LAB_LABEL:-compose-lab}"   # Label lab=… für docker run im Buch
export PROJECT="${COMPOSE_PROJECT_NAME:-notes}" # Compose-Projekt (name: notes)
# Basis-Images des Buchs (Stand Tag 0, geprüft gegen Docker Hub und GHCR)
export LAB_IMAGES="postgres:18.6-alpine golang:1.27-alpine python:3.15-slim \
node:26-alpine ghcr.io/astral-sh/uv:0.13.6"
