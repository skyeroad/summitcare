class RecoveryCode < ApplicationRecord
  belongs_to :user

  def self.digest(code) = OpenSSL::Digest::SHA256.hexdigest(code.to_s.downcase.delete("^a-z0-9"))

  def self.generate_for!(user, count: 10)
    codes = Array.new(count) { SecureRandom.alphanumeric(16).downcase.scan(/.{4}/).join("-") }
    transaction do
      user.recovery_codes.delete_all
      codes.each { |code| user.recovery_codes.create!(code_digest: digest(code)) }
    end
    codes
  end

  def self.redeem(user, code)
    user.recovery_codes.where(used_at: nil, code_digest: digest(code))
        .update_all(used_at: Time.current) == 1
  end
end
