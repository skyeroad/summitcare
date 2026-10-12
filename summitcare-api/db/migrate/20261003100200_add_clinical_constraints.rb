class AddClinicalConstraints < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint :appointments, "ends_at > starts_at", name: "appointments_end_after_start"
    add_foreign_key :lab_results, :patients
    change_column_null :lab_results, :resulted_at, false
    add_index :patients, :mrn, unique: true # skip if Solution 7 added it; works with deterministic encryption
  end
end
