class RestoreIntegrityCheck
  class DrillRecord < ActiveRecord::Base
    self.abstract_class = true
  end

  TABLES = { "patients" => [Patient, :created_at], "lab_results" => [LabResult, :created_at],
             "messages" => [Message, :created_at], "audit_events" => [AuditEvent, :occurred_at] }.freeze

  def initialize(host:, snapshot_taken_at:)
    @host, @cutoff = host, snapshot_taken_at
  end

  def run
    DrillRecord.establish_connection(adapter: "postgresql", host: @host,
      database: "summitcare_production", username: "restore_drill",
      password: Rails.application.credentials.dig(:restore_drill, :password),
      sslmode: "verify-full", sslrootcert: Rails.root.join("config/certs/rds-global-bundle.pem").to_s)
    DrillRecord.with_connection do |conn|
      { row_counts: row_counts(conn), decrypt_sample: decrypt_sample(conn), audit_chain: audit_chain(conn) }
    end
  ensure
    DrillRecord.remove_connection
  end

  private

  def row_counts(conn)
    tables = TABLES.to_h do |table, (model, column)|
      sql = DrillRecord.sanitize_sql_array(["SELECT count(*) FROM #{table} WHERE #{column} <= ?", @cutoff])
      [table, { restored: conn.select_value(sql), primary: model.where(column => ..@cutoff).count }]
    end
    { ok: tables.values.all? { |t| t[:restored] == t[:primary] }, tables: }
  end

  def decrypt_sample(conn)
    ciphertext = conn.select_value("SELECT last_name FROM patients ORDER BY random() LIMIT 1")
    plaintext = Patient.type_for_attribute(:last_name).deserialize(ciphertext)
    { ok: plaintext.present? && plaintext != ciphertext } # never log the value
  rescue ActiveRecord::Encryption::Errors::Decryption
    { ok: false, error: "decryption_failed" }
  end

  def audit_chain(conn)
    broken = conn.select_value(<<~SQL)
      SELECT count(*) FROM (
        SELECT previous_digest, LAG(digest) OVER (ORDER BY id) AS expected FROM audit_events
      ) chain WHERE expected IS NOT NULL AND previous_digest IS DISTINCT FROM expected
    SQL
    { ok: broken.zero?, broken_links: broken }
  end
end
