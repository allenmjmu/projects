CREATE GROUP r_access;

GRANT CONNECT ON DATABASE name TO r_access;
ALTER DEFAULT PRIVILEGES GRANT SELECT ON TABLES TO r_access;
GRANT USAGE ON SCHEMA public TO r_access;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO r_access;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO r_access;