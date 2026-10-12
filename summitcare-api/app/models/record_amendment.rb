class RecordAmendment < ApplicationRecord
  include ProtectedHealthInformation
  phi_attributes :body

  KINDS = %w[amendment denial disagreement rebuttal].freeze

  belongs_to :amendment_request
  belongs_to :target, polymorphic: true
  belongs_to :author, class_name: "User", optional: true

  validates :kind, inclusion: { in: KINDS }
  def readonly? = persisted?
end
