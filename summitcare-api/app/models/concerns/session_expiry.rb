module SessionExpiry
  extend ActiveSupport::Concern

  IDLE_TIMEOUT = 15.minutes
  ABSOLUTE_TIMEOUT = 12.hours
  TOUCH_INTERVAL = 1.minute

  class_methods do
    attr_reader :activity_column
    def tracks_activity_in(column) = @activity_column = column
  end

  def last_activity_at = self[self.class.activity_column] || created_at

  def timeout_reason(now = Time.current)
    if created_at <= now - ABSOLUTE_TIMEOUT then "absolute_timeout"
    elsif last_activity_at <= now - IDLE_TIMEOUT then "idle_timeout"
    end
  end

  def record_activity!(now = Time.current)
    return if last_activity_at > now - TOUCH_INTERVAL
    update_column(self.class.activity_column, now)
  end
end
