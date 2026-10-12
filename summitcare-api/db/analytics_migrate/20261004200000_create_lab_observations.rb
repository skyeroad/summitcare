# The de-identified analytics database (Solution 22). Only allowlisted,
# Safe Harbor columns; test/services/deidentify/safe_harbor_test.rb checks them.
class CreateLabObservations < ActiveRecord::Migration[8.0]
  def change
    create_table :lab_observations, id: false do |t|
      t.string :subject_key, null: false
      t.integer :birth_year
      t.boolean :age_90_plus, null: false, default: false
      t.string :state
      t.string :zip3
      t.integer :result_year
      t.string :loinc_code
      t.float :value_numeric
      t.string :unit
    end
    add_index :lab_observations, :subject_key
  end
end
