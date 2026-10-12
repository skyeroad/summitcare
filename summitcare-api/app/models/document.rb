class Document < ApplicationRecord
  include ProtectedHealthInformation
  include Amendable
  class IntegrityError < StandardError; end
  ALLOWED_TYPES = %w[application/pdf image/jpeg image/png image/heic].freeze
  KINDS = %w[insurance_card outside_record referral consent other].freeze

  belongs_to :patient
  belongs_to :uploaded_by, class_name: "User"
  has_one_attached :file
  phi_attributes :title

  validates :kind, inclusion: { in: KINDS }
  validate :file_is_acceptable

  def self.checksum_for(path) = Digest::SHA256.file(path).hexdigest

  def verify_checksum!
    digest = OpenSSL::Digest::SHA256.new
    file.download { |chunk| digest.update(chunk) }
    return true if ActiveSupport::SecurityUtils.secure_compare(digest.hexdigest, checksum)
    raise IntegrityError, "Document #{id} failed checksum verification"
  end

  private

  def file_is_acceptable
    return errors.add(:file, "is required") unless file.attached?
    errors.add(:file, "type is not allowed") unless file.blob.content_type.in?(ALLOWED_TYPES)
    errors.add(:file, "is too large") if file.blob.byte_size > 25.megabytes
  end
end
