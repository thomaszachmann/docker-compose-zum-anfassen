# notes – Demo-Anwendung für „Docker Compose zum Anfassen"

| Dienst | Sprache | Port | Zweck |
|---|---|---|---|
| notes-api | Go 1.27 | 8080 | Notizen speichern (Speicher oder Postgres); POST verlangt `X-API-Key` |
| notes-worker | Python 3.15 + uv | – | fasst die Notizen periodisch zusammen |
| notes-web | Node 26 | 3000 | Oberfläche plus Proxy auf notes-api |
| db (ab Tag 3) | Postgres 18 | 5432 | Image `postgres:18.6-alpine`, kein eigenes Dockerfile |

Die Dockerfiles sind der Endstand aus „Dockerfiles zum Anfassen" (Multi-Stage,
non-root, Healthcheck in notes-api). Eine `compose.yaml` gibt es noch nicht – sie
entsteht an Tag 1.

notes-api:

- API-Key aus `NOTES_API_KEY_FILE` (bevorzugt) oder `NOTES_API_KEY`.
- Datenbank-URL aus `NOTES_DB_URL_FILE` (bevorzugt) oder `NOTES_DB_URL`, z. B.
  `postgres://notes:lab-db-pw-123@db:5432/notes`. Ohne URL: Speicherbetrieb.
- `notes-api migrate` legt die Tabelle `notes` an (idempotent) und endet mit 0.
- `notes-api healthcheck` prüft `/healthz`; mit Datenbank antwortet `/healthz` nur
  dann mit 200, wenn die Datenbank erreichbar ist.
- `GET /metrics` liefert Kennzahlen im Prometheus-Textformat.

`.env` enthält nur Lab-Werte (`lab-…`), `.env.example` die Vorlage ohne Werte.
