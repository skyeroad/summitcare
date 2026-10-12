class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :device_sessions, dependent: :destroy
  has_many :webauthn_credentials, dependent: :destroy
  has_many :recovery_codes, dependent: :delete_all
  has_one :patient # a patient's own login (optional)
  include Mfa

  enum :role, %w[patient clinician front_desk billing admin compliance_officer].index_by(&:itself)
  encrypts :otp_secret
  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 15 }, allow_nil: true
  validate :password_not_breached, if: -> { password.present? }

  before_create { self.webauthn_id ||= WebAuthn.generate_user_id }

  def active? = deactivated_at.nil?
  def mfa_required? = !patient?
  def mfa_enrolled? = otp_enabled_at.present? || webauthn_credentials.exists?

  BREACHED_PASSWORDS_FILE = Rails.root.join("config/breached_passwords.txt")

  def self.breached_passwords
    @breached_passwords ||= File.exist?(BREACHED_PASSWORDS_FILE) ?
      File.readlines(BREACHED_PASSWORDS_FILE, chomp: true).reject { _1.blank? || _1.start_with?("#") }.to_set :
      Set.new
  end

  private

  # Local blocklist check (NIST SP 800-63B). An external range-query service
  # would be a vendor and belongs in config/vendors.yml (Solution 23).
  def password_not_breached
    errors.add(:password, "appears in a known breach corpus") if self.class.breached_passwords.include?(password.downcase)
  end
end
