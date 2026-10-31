-- Testdaten für die Demo (Tag 15, Runde 3) – braucht ein paar Sekunden
SELECT pg_sleep(8);
CREATE TABLE IF NOT EXISTS demo_seed (id int PRIMARY KEY, label text);
INSERT INTO demo_seed SELECT g, 'seed ' || g FROM generate_series(1, 1000) AS g;
