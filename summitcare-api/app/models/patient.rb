class Patient < ApplicationRecord
  include ProtectedHealthInformation

  belongs_to :user, optional: true
  has_many :care_team_memberships, dependent: :destroy
  has_many :clinicians, through: :care_team_memberships, source: :user
  has_many :appointments, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :lab_results, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :record_requests, dependent: :destroy
  has_many :accounting_requests, dependent: :destroy
  has_many :disclosures, dependent: :restrict_with_exception
  has_many :amendment_requests, dependent: :destroy
  has_many :communication_preferences, dependent: :destroy
  has_many :patient_authorizations, dependent: :destroy
  has_many :legal_holds, dependent: :restrict_with_exception

  attribute :date_of_birth, :date # stored as encrypted text
  phi_attributes :first_name, :last_name, :date_of_birth, :phone,
                 :address_line1, :city, :state, :postal_code
  phi_attributes :mrn, deterministic: true
  phi_attributes :email, deterministic: true, downcase: true

  # Exact-match phone lookup on an encrypted column (Solution 7).
  blind_index :phone, expression: ->(value) { value.to_s.gsub(/\D/, "") }

  after_create :create_default_communication_preferences

  def full_name = [first_name, last_name].compact.join(" ")

  # If any confidential destination exists, use only confidential destinations.
  def contact_points
    prefs = communication_preferences.to_a
    confidential = prefs.select(&:confidential?)
    confidential.any? ? confidential : prefs
  end

  private

  # Default preferences from the patient's own email and phone (Solution 21).
  def create_default_communication_preferences
    communication_preferences.create!(channel: "email", destination: email) if email.present?
    communication_preferences.create!(channel: "sms", destination: phone) if phone.present?
  end
end
