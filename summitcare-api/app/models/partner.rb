# A partner organization and how HIPAA classifies it (Solution 27).
class Partner < ApplicationRecord
  RELATIONSHIPS = %w[covered_entity_treatment business_associate public_health_authority].freeze

  has_many :partner_credentials, dependent: :destroy
  has_many :webhook_receipts, dependent: :delete_all
  encrypts :webhook_secret

  validates :name, presence: true
  validates :relationship, inclusion: { in: RELATIONSHIPS }
end
