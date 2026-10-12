-- Database roles for local development (Solution 13). In production, migrations
-- run as the table owner and the app connects as summitcare_app.
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'summitcare_app') THEN
    CREATE ROLE summitcare_app LOGIN;
  END IF;
END
$$;
