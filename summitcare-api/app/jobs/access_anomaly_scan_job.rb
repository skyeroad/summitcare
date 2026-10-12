class AccessAnomalyScanJob < ApplicationJob
  CLINIC_TIME_ZONE = "America/Denver"
  STAFF_ROLES = %w[clinician front_desk billing admin].freeze
  THRESHOLDS = { distinct_patients_per_hour: 40, failed_sign_ins_per_account: 5,
                 failed_sign_ins_per_ip: 20 }.freeze

  def perform(window_end: Time.current.beginning_of_hour)
    @window = (window_end - 1.hour)...window_end
    @events = AuditEvent.where(occurred_at: @window)
    created = [bulk_access, outside_care_team, after_hours, monitored_patients,
               failed_sign_ins].sum
    ComplianceMailer.findings_ready(created).deliver_later if created.positive?
  end

  private

  def record(kind, actor_id: nil, **details)
    AnomalyFinding.find_or_create_by!(kind:, actor_id:, window_start: @window.begin) do |f|
      f.details = details
      f.status = "open"
    end.previously_new_record? ? 1 : 0
  end

  def bulk_access
    counts = @events.where(action: %w[view download export], actor_role: STAFF_ROLES)
                    .where.not(patient_id: nil).group(:actor_id)
                    .having("COUNT(DISTINCT patient_id) > ?", THRESHOLDS[:distinct_patients_per_hour])
                    .distinct.count(:patient_id)
    counts.sum { |actor_id, n| record("bulk_access", actor_id:, distinct_patients: n) }
  end

  def outside_care_team
    rows = @events.where(actor_role: "clinician").where.not(patient_id: nil)
                  .where("metadata->>'break_glass_grant_id' IS NULL")
                  .where(<<~SQL).group(:actor_id).pluck(:actor_id, Arel.sql("array_agg(DISTINCT patient_id)"))
                    NOT EXISTS (SELECT 1 FROM care_team_memberships ctm
                      WHERE ctm.patient_id = audit_events.patient_id
                        AND ctm.user_id = audit_events.actor_id
                        AND ctm.starts_on <= audit_events.occurred_at::date
                        AND (ctm.ends_on IS NULL OR ctm.ends_on > audit_events.occurred_at::date))
                  SQL
    rows.sum { |actor_id, ids| record("outside_care_team", actor_id:, patient_ids: ids) }
  end

  def after_hours
    local_hour = "EXTRACT(HOUR FROM (audit_events.occurred_at AT TIME ZONE 'UTC') AT TIME ZONE ?)"
    rows = @events.where(actor_role: STAFF_ROLES).where.not(patient_id: nil)
                  .where("#{local_hour} NOT BETWEEN 7 AND 18", CLINIC_TIME_ZONE)
                  .group(:actor_id).distinct.count(:patient_id)
    rows.sum { |actor_id, n| record("after_hours", actor_id:, distinct_patients: n) }
  end

  def monitored_patients
    rows = @events.joins("JOIN patients ON patients.id = audit_events.patient_id")
                  .where(patients: { monitored: true }, actor_role: STAFF_ROLES)
                  .group(:actor_id).pluck(:actor_id, Arel.sql("array_agg(DISTINCT audit_events.patient_id)"))
    rows.sum { |actor_id, ids| record("monitored_patient", actor_id:, patient_ids: ids) }
  end

  def failed_sign_ins
    failed = @events.where(action: "sign_in_failed")
    by_account = failed.where(subject_type: "User").group(:subject_id)
                       .having("COUNT(*) >= ?", THRESHOLDS[:failed_sign_ins_per_account]).count
    by_ip = failed.group(:ip_address).having("COUNT(*) >= ?", THRESHOLDS[:failed_sign_ins_per_ip]).count
    by_account.sum { |user_id, n| record("failed_sign_ins_account", actor_id: user_id, attempts: n) } +
      by_ip.sum { |ip, n| record("failed_sign_ins_ip", ip: ip.to_s, attempts: n) }
  end
end
