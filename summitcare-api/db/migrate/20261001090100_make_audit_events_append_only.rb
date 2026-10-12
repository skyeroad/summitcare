# The summitcare_app role must exist first (bin/setup runs db/roles.sql).
class MakeAuditEventsAppendOnly < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      CREATE FUNCTION audit_events_reject_change() RETURNS trigger
      LANGUAGE plpgsql AS $$
      BEGIN
        RAISE EXCEPTION 'audit_events is append-only (% rejected)', TG_OP;
      END;
      $$;

      CREATE TRIGGER audit_events_no_update_delete
        BEFORE UPDATE OR DELETE ON audit_events
        FOR EACH ROW EXECUTE FUNCTION audit_events_reject_change();

      CREATE TRIGGER audit_events_no_truncate
        BEFORE TRUNCATE ON audit_events
        FOR EACH STATEMENT EXECUTE FUNCTION audit_events_reject_change();

      REVOKE UPDATE, DELETE, TRUNCATE ON audit_events FROM summitcare_app;
      GRANT SELECT, INSERT ON audit_events TO summitcare_app;
      GRANT USAGE ON SEQUENCE audit_events_id_seq TO summitcare_app;
    SQL
  end
  # down omitted: dropping these protections should be a deliberate, reviewed migration
end
