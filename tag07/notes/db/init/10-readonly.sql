-- Läuft nur beim ersten Start mit leerem Volume (docker-entrypoint-initdb.d)
CREATE ROLE notes_ro NOLOGIN;
GRANT pg_read_all_data TO notes_ro;
