module Deidentify
  class SafeHarbor
    RESTRICTED_ZIP3 = YAML.load_file(Rails.root.join("config/restricted_zip3.yml")).to_set

    def initialize(pseudonymizer: Pseudonymizer.new, today: Date.current)
      @pseudonymizer = pseudonymizer
      @today = today
    end

    def lab_observation(lab)
      patient = lab.patient
      over_89 = age_on(patient.date_of_birth, @today) > 89
      {
        subject_key: @pseudonymizer.key_for(patient),
        birth_year: over_89 ? nil : patient.date_of_birth.year,
        age_90_plus: over_89,
        state: patient.state,
        zip3: zip3(patient.postal_code),
        result_year: lab.resulted_at.year,
        loinc_code: lab.test_code,
        value_numeric: Float(lab.value, exception: false),
        unit: lab.unit
      } # never copied: names, MRN, phone, email, street, city, full dates, notes
    end

    private

    def zip3(postal_code)
      prefix = postal_code.to_s[0, 3]
      prefix.length < 3 || RESTRICTED_ZIP3.include?(prefix) ? "000" : prefix
    end

    def age_on(dob, date)
      had_birthday = (date.month * 100 + date.day) >= (dob.month * 100 + dob.day)
      date.year - dob.year - (had_birthday ? 0 : 1)
    end
  end
end
