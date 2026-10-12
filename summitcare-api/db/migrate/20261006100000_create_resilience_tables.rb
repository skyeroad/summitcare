# Restore drills (Solution 28), legal holds (Solution 29), incidents (Solution 31),
# and control runs for the evidence pack (Solution 35).
class CreateResilienceTables < ActiveRecord::Migration[8.0]
  def change
    create_table :backup_restore_drills do |t|
      t.string :instance_id, null: false
      t.string :snapshot_id
      t.datetime :snapshot_taken_at
      t.datetime :started_at, null: false
      t.datetime :available_at
      t.datetime :completed_at
      t.jsonb :checks, null: false, default: {}
      t.boolean :passed
      t.timestamps
    end

    create_table :legal_holds do |t|
      t.references :patient, null: false, foreign_key: true
      t.text :reason, null: false
      t.references :placed_by, null: false, foreign_key: { to_table: :users }
      t.datetime :placed_at, null: false
      t.datetime :released_at
      t.timestamps
    end

    create_table :incidents do |t|
      t.datetime :detected_at, null: false
      t.references :reported_by, null: false, foreign_key: { to_table: :users }
      t.text :summary, null: false
      t.string :status, null: false, default: "open"
      t.boolean :phi_involved, null: false, default: false
      t.jsonb :risk_assessment, null: false, default: {}
      t.string :breach_determination, null: false, default: "pending"
      t.datetime :discovered_at
      t.date :notification_deadline
      t.timestamps
    end

    create_table :incident_affected_patients do |t|
      t.references :incident, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.datetime :notified_at
      t.string :notice_method
      t.timestamps
    end
    add_index :incident_affected_patients, [:incident_id, :patient_id], unique: true

    create_table :control_runs do |t|
      t.string :control, null: false
      t.boolean :succeeded, null: false
      t.datetime :ran_at, null: false
      t.jsonb :details, null: false, default: {}
      t.timestamps
    end
    add_index :control_runs, [:control, :ran_at]
  end
end
