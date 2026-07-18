CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS mart;

COMMENT ON SCHEMA raw  IS 'Raw source data, no changes';
COMMENT ON SCHEMA stg  IS 'Typed, deduplicated, normalized';
COMMENT ON SCHEMA core IS 'Star schema: dimensions and facts';
COMMENT ON SCHEMA mart IS 'Data marts for BI';

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bi_reader') THEN
        CREATE ROLE bi_reader LOGIN PASSWORD 'bi_reader_local';
    END IF;
END
$$;

GRANT USAGE ON SCHEMA mart TO bi_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA mart TO bi_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA mart GRANT SELECT ON TABLES TO bi_reader;
CREATE SCHEMA IF NOT EXISTS;
