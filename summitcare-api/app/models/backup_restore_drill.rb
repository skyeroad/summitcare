# One row per timed restore drill (Solution 28). started_at to completed_at is
# the measured database recovery time.
class BackupRestoreDrill < ApplicationRecord
  def elapsed_minutes = completed_at && ((completed_at - started_at) / 60).round(1)
end
