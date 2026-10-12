# Core clinical tables. PHI columns are text because Active Record Encryption
# stores ciphertext as a JSON string (Solution 7). lab_results gets its foreign
# key and NOT NULL resulted_at in AddClinicalConstraints (Solution 16).
class CreateClinicalTables < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.references :user, foreign_key: true # the patient's own login, optional
      t.text :mrn
      t.text :first_name
      t.text :last_name
      t.text :date_of_birth
      t.text :phone
      t.string :phone_bidx
      t.text :email
      t.text :address_line1
      t.text :city
      t.text :state
      t.text :postal_code
      t.boolean :monitored, null: false, default: false # Solution 17
      t.timestamps
    end
    add_index :patients, :phone_bidx
    add_index :patients, :email

    create_table :care_team_memberships do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "primary_care"
      t.date :starts_on, null: false
      t.date :ends_on # exclusive
      t.timestamps
    end

    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :clinician, null: false, foreign_key: { to_table: :users }
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.text :reason
      t.string :status, null: false, default: "scheduled"
      t.timestamps
    end

    create_table :messages do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body
      t.datetime :read_at
      t.timestamps
    end

    create_table :lab_results do |t|
      t.bigint :patient_id, null: false
      t.references :ordered_by, foreign_key: { to_table: :users }
      t.string :test_code
      t.string :test_name
      t.text :value
      t.string :unit
      t.string :reference_range
      t.datetime :resulted_at
      t.text :notes
      t.timestamps
    end
    add_index :lab_results, :patient_id

    create_table :documents do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.string :kind, null: false
      t.text :title
      t.string :checksum
      t.timestamps
    end

    create_table :break_glass_grants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.text :reason, null: false
      t.datetime :granted_at, null: false
      t.datetime :expires_at, null: false
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.string :review_outcome
      t.timestamps
    end
  end
end
