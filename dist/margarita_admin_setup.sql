CREATE SCHEMA pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
CREATE EXTENSION IF NOT EXISTS plpgsql;
COMMENT ON EXTENSION plpgsql IS 'plpgsql/Language';
