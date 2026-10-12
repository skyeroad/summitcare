class ClinicalVersion < ApplicationRecord
  include PaperTrail::VersionConcern
  self.table_name = "clinical_versions"
  encrypts :object, :object_changes
end
