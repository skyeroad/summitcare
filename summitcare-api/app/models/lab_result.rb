class LabResult < ApplicationRecord
  include ProtectedHealthInformation
  include Amendable
  phi_attributes :value, :notes
  has_paper_trail versions: { class_name: "ClinicalVersion" },
                  meta: { request_id: ->(_record) { Current.request_id } }
  belongs_to :patient
  belongs_to :ordered_by, class_name: "User", optional: true
end
