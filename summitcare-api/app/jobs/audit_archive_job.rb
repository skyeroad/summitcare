class AuditArchiveJob < ApplicationJob
  BUCKET = "summitcare-audit-archive"

  def perform(day = Time.now.utc.to_date - 1)
    events = AuditEvent.where(occurred_at: day.in_time_zone("UTC").all_day).order(:id).to_a
    return if events.empty?

    body = events.map { |e| e.attributes.merge("ip_address" => e.ip_address&.to_s).to_json }.join("\n")
    last = events.last
    Aws::S3::Client.new.put_object(
      bucket: BUCKET, key: "audit-events/#{day.iso8601}.jsonl", body: "#{body}\n",
      checksum_algorithm: "SHA256", # Object Lock uploads need Content-MD5 or an SDK checksum
      metadata: { "last-event-id" => last.id.to_s, "last-digest" => last.digest }
    )
  end
end
