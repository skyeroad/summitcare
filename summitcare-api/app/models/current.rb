class Current < ActiveSupport::CurrentAttributes
  attribute :session, :device_session, :user
  attribute :request_id, :ip_address, :user_agent
  attribute :break_glass_grant

  def session=(value)
    super
    self.user = value&.user
  end
end
