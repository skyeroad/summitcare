class BackupRestoreDrillJob < ApplicationJob
  queue_as :maintenance
  SOURCE = "summitcare-production"

  def perform
    @rds = Aws::RDS::Client.new
    @drill = BackupRestoreDrill.create!(started_at: Time.current,
                                        instance_id: "summitcare-drill-#{Time.current.to_i}")
    restore_latest_snapshot
    host = @rds.describe_db_instances(db_instance_identifier: @drill.instance_id)
               .db_instances.first.endpoint.address
    checks = RestoreIntegrityCheck.new(host:, snapshot_taken_at: @drill.snapshot_taken_at).run
    @drill.update!(checks:, passed: checks.values.all? { |c| c[:ok] }, completed_at: Time.current)
    ControlRun.create!(control: "backup_restore_drill", succeeded: @drill.passed, ran_at: Time.current,
                       details: { drill_id: @drill.id }) # read by the evidence pack (Solution 35)
  rescue => error
    @drill&.update!(passed: false, checks: { error: error.class.name })
    raise
  ensure
    tear_down if @drill&.snapshot_id
  end

  private

  def restore_latest_snapshot
    snapshot = @rds.describe_db_snapshots(db_instance_identifier: SOURCE, snapshot_type: "automated")
                   .db_snapshots.select { |s| s.status == "available" }.max_by(&:snapshot_create_time)
    @drill.update!(snapshot_id: snapshot.db_snapshot_identifier,
                   snapshot_taken_at: snapshot.snapshot_create_time)
    @rds.restore_db_instance_from_db_snapshot(
      db_instance_identifier: @drill.instance_id,
      db_snapshot_identifier: snapshot.db_snapshot_identifier,
      db_instance_class: "db.t4g.large",
      db_subnet_group_name: "summitcare-drill-isolated",
      vpc_security_group_ids: [ENV.fetch("DRILL_SECURITY_GROUP_ID")],
      publicly_accessible: false, deletion_protection: false)
    @rds.wait_until(:db_instance_available, { db_instance_identifier: @drill.instance_id }) do |w|
      w.max_attempts = 120
      w.delay = 30
    end
    @drill.update!(available_at: Time.current)
  end

  def tear_down
    @rds.delete_db_instance(db_instance_identifier: @drill.instance_id,
                            skip_final_snapshot: true, delete_automated_backups: true)
  rescue Aws::RDS::Errors::ServiceError => e
    Rails.logger.error({ event: "restore_drill.teardown_failed", error: e.class.name }.to_json)
  end
end
