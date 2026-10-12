# The mailing list and the proof of notice for an incident (Solution 31).
class IncidentAffectedPatient < ApplicationRecord
  belongs_to :incident
  belongs_to :patient
end
