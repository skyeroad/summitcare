# Synthetic data only (Solution 32). Every name, MRN, and date here is invented.
if Rails.env.production?
  abort "db:seed loads synthetic data only. It never runs in production."
end

okafor = User.find_or_create_by!(email_address: "sam.okafor@staff.summitcare.example") do |user|
  user.role = "clinician"
  user.password = ENV.fetch("SEED_PASSWORD")
end

Patient.find_or_create_by!(mrn: "SC-100231") do |patient|
  patient.assign_attributes(first_name: "Avery", last_name: "Quinn",
                            date_of_birth: Date.new(1984, 3, 12))
end
Patient.find_or_create_by!(mrn: "SC-100877") do |patient|
  patient.assign_attributes(first_name: "Jordan", last_name: "Ellis",
                            date_of_birth: Date.new(1991, 7, 23))
end
Patient.find_or_create_by!(mrn: "SC-101442") do |patient|
  patient.assign_attributes(first_name: "Riley", last_name: "Navarro",
                            date_of_birth: Date.new(1958, 11, 2))
end

synthea_dir = Rails.root.join("tmp/synthea/fhir")
SyntheaImporter.new(synthea_dir, clinician: okafor).import! if synthea_dir.exist?
