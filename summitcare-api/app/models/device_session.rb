class DeviceSession < ApplicationRecord
  include SessionExpiry
  tracks_activity_in :last_seen_at

  ACCESS_TOKEN_TTL = 15.minutes
  SESSION_LIFETIME = 12.hours # same as SessionExpiry::ABSOLUTE_TIMEOUT (Solution 5)
  REVOKED_REASONS = %w[refresh_token_reuse idle_timeout absolute_timeout reported_lost offboarded signed_out].freeze

  belongs_to :user
  scope :live, -> { where(revoked_at: nil) }

  def self.digest(token) = OpenSSL::Digest::SHA256.hexdigest(token.to_s)

  def self.start!(user:, device_id:, device_name:)
    transaction do
      session = create!(user:, device_id:, device_name:, last_seen_at: Time.current,
                        refresh_expires_at: SESSION_LIFETIME.from_now)
      [session, session.issue_tokens!]
    end
  end

  def self.find_by_access_token(token)
    live.where("access_expires_at > ?", Time.current)
        .find_by(access_token_digest: digest(token))
  end

  # Current or previous refresh token, revoked or not (Solution 30 uses this to
  # tell the app its device was revoked).
  def self.find_by_refresh_token(token)
    digest = digest(token)
    find_by(refresh_token_digest: digest) || find_by(previous_refresh_token_digest: digest)
  end

  def self.refresh(token, device_id:)
    digest = digest(token)
    session = find_by(refresh_token_digest: digest) || find_by(previous_refresh_token_digest: digest)
    return unless session

    session.with_lock do
      if session.refresh_token_digest != digest
        session.revoke!("refresh_token_reuse")
        nil
      elsif session.refreshable?(device_id)
        session.issue_tokens!
      end
    end
  end

  def issue_tokens!
    access, refresh = SecureRandom.urlsafe_base64(32), SecureRandom.urlsafe_base64(32)
    update!(access_token_digest: self.class.digest(access),
            previous_refresh_token_digest: refresh_token_digest,
            refresh_token_digest: self.class.digest(refresh),
            access_expires_at: ACCESS_TOKEN_TTL.from_now,
            last_seen_at: Time.current)
    { access_token: access, refresh_token: refresh, expires_in: ACCESS_TOKEN_TTL.to_i }
  end

  def refreshable?(presented_device_id)
    if (reason = timeout_reason) # Solution 5: revoke, so the reason is reportable
      revoke!(reason)
      return false
    end
    revoked_at.nil? && refresh_expires_at.future? && user.active? &&
      ActiveSupport::SecurityUtils.secure_compare(device_id, presented_device_id.to_s)
  end

  def revoke!(reason)
    update!(revoked_at: Time.current, revoked_reason: reason) if revoked_at.nil?
  end
end
