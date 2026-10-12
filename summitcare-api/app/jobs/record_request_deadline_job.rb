class RecordRequestDeadlineJob < ApplicationJob
  WARN_AT = [10, 5, 2, 0].freeze # days remaining

  def perform(today: Date.current)
    RecordRequest.outstanding.find_each do |record_request|
      days_left = (record_request.effective_due_on - today).to_i
      if days_left.negative?
        ComplianceMailer.record_request_overdue(record_request).deliver_later
      elsif WARN_AT.include?(days_left)
        ComplianceMailer.record_request_due(record_request, days_left:).deliver_later
      end
    end
  end
end
