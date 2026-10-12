# When a scheduled control (restore drill, audit chain verification) last ran
# and whether it passed (Solution 35). Timestamps and outcomes only, never PHI.
class ControlRun < ApplicationRecord
  CONTROLS = %w[backup_restore_drill audit_chain_verification].freeze

  validates :control, inclusion: { in: CONTROLS }
  validates :ran_at, presence: true

  def self.record!(control, succeeded:, details: {})
    create!(control:, succeeded:, ran_at: Time.current, details:)
  end
end
