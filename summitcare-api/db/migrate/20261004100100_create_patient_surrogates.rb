# Random, stable pseudonyms for de-identified exports (Solution 22). Lives in the
# primary (PHI) database so the mapping never reaches the analytics database.
class CreatePatientSurrogates < ActiveRecord::Migration[8.0]
  def change
    create_table :patient_surrogates do |t|
      t.references :patient, null: false, foreign_key: true, index: { unique: true }
      t.uuid :surrogate_id, null: false
      t.timestamps
    end
    add_index :patient_surrogates, :surrogate_id, unique: true
  end
end
