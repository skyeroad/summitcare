class PartnerCredential < ApplicationRecord
  belongs_to :partner
  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def self.issue!(partner:, scopes:, expires_at: 90.days.from_now)
    lookup_id = SecureRandom.alphanumeric(12)
    secret = SecureRandom.alphanumeric(40)
    create!(partner:, scopes:, expires_at:, lookup_id:, secret_digest: digest(secret))
    "scp_#{lookup_id}_#{secret}"   # shown to the partner once, never stored
  end

  def self.authenticate(token)
    lookup_id, secret = token.to_s.delete_prefix("scp_").split("_", 2)
    credential = active.find_by(lookup_id: lookup_id) or return nil
    ActiveSupport::SecurityUtils.secure_compare(credential.secret_digest, digest(secret.to_s)) ? credential : nil
  end

  def self.digest(secret) = OpenSSL::Digest::SHA256.hexdigest(secret)
  def allows?(scope) = scopes.include?(scope)
end
