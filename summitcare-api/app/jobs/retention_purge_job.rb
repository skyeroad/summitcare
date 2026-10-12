class RetentionPurgeJob < ApplicationJob
  queue_as :maintenance

  def perform(mode = "dry_run")
    RetentionPolicy.all.each do |policy|
      scope = policy.expired_scope
      Rails.logger.info({ event: "retention.scan", policy: policy.key, mode:, count: scope.count }.to_json)
      next unless mode == "execute"

      scope.find_each { |record| dispose(record, policy) }
    end
  end

  private

  def dispose(record, policy)
    AuditLog.record!(action: "delete", subject: record, patient: record.try(:patient),
                     reason: "retention:#{policy.key}",
                     metadata: { legal_basis: policy.legal_basis, trigger: record[policy.trigger_column] })
    DocumentDisposal.call(record) if record.is_a?(Document)
    PaperTrail.request(enabled: false) { record.destroy! }
    ClinicalVersion.where(item_type: record.class.name, item_id: record.id).delete_all # Solution 16
  end
end
