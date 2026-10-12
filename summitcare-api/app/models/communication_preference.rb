class CommunicationPreference < ApplicationRecord
  include ProtectedHealthInformation
  phi_attributes :destination

  CHANNELS = %w[email sms push mail].freeze

  belongs_to :patient
  validates :channel, inclusion: { in: CHANNELS }
  validates :destination, presence: true, unless: -> { channel == "push" }
end
