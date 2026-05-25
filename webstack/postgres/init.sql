-- -------------------------------------------------------
-- Initial database setup
-- -------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Application user with limited privileges
CREATE USER app_readonly WITH PASSWORD 'readonly_changeme';

-- Schema
CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION appuser;

-- Example table
CREATE TABLE IF NOT EXISTS app.users (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username    VARCHAR(50)  UNIQUE NOT NULL,
    email       VARCHAR(255) UNIQUE NOT NULL,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS app.audit_log (
    id          BIGSERIAL PRIMARY KEY,
    user_id     UUID REFERENCES app.users(id),
    action      VARCHAR(100) NOT NULL,
    details     JSONB,
    ip_address  INET,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON app.audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON app.audit_log(created_at);

GRANT USAGE ON SCHEMA app TO app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO app_readonly;
