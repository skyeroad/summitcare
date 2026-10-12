# Maps a patient to the random surrogate ID used in de-identified data (Solution 22).
class PatientSurrogate < ApplicationRecord
  belongs_to :patient
end
