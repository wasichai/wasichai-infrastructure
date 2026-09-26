-- Runs once, on an empty data directory, as the superuser.
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;

-- wasichai  : platform metadata and identity (fixed schema, owned by Flyway)
-- app_data: business data, one physical table per Custom Object (owned by WASICHAI at runtime)
CREATE SCHEMA IF NOT EXISTS wasichai;
CREATE SCHEMA IF NOT EXISTS app_data;
