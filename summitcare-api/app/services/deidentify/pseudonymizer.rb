module Deidentify
  class Pseudonymizer
    # patient_surrogates lives in the primary (PHI) database; patient_id has a unique index.
    def key_for(patient)
      PatientSurrogate.create_or_find_by!(patient_id: patient.id) do |surrogate|
        surrogate.surrogate_id = SecureRandom.uuid
      end.surrogate_id
    end
  end
end
