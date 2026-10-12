require "test_helper"

class RecurringScheduleTest < ActiveSupport::TestCase
  test "restore drill is scheduled in production" do
    config = YAML.load_file(Rails.root.join("config/recurring.yml"), aliases: true)
    assert_equal "BackupRestoreDrillJob", config.dig("production", "backup_restore_drill", "class")
  end
end
