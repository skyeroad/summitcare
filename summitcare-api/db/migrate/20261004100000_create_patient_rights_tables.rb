# Patient rights (Solutions 18 to 21).
class CreatePatientRightsTables < ActiveRecord::Migration[8.0]
  def change
    create_table :record_requests do |t| # Solution 18
      t.references :patient, null: false, foreign_key: true
      t.datetime :requested_at, null: false
      t.date :due_on, null: false
      t.date :extended_due_on
      t.string :format, null: false
      t.string :status, null: false, default: "received"
      t.datetime :fulfilled_at
      t.timestamps
    end

    create_table :accounting_requests do |t| # Solution 19
      t.references :patient, null: false, foreign_key: true
      t.datetime :requested_at, null: false
      t.date :due_on, null: false
      t.date :extended_due_on
      t.string :format, null: false, default: "pdf"
      t.string :status, null: false, default: "received"
      t.datetime :fulfilled_at
      t.timestamps
    end

    create_table :disclosures do |t| # Solution 19
      t.references :patient, null: false, foreign_key: true
      t.string :recipient_name, null: false
      t.string :recipient_address
      t.string :purpose, null: false
      t.text :description
      t.datetime :disclosed_at, null: false
      t.references :disclosed_by, foreign_key: { to_table: :users }
      t.boolean :accountable, null: false, default: true
      t.timestamps
    end
    add_index :disclosures, [:patient_id, :disclosed_at]

    create_table :amendment_requests do |t| # Solution 20
      t.references :patient, null: false, foreign_key: true
      t.references :target, polymorphic: true, null: false
      t.text :requested_change
      t.text :reason
      t.string :status, null: false, default: "submitted"
      t.references :decided_by, foreign_key: { to_table: :users }
      t.datetime :decided_at
      t.string :denial_basis
      t.date :due_on, null: false
      t.date :extended_due_on
      t.jsonb :notify_recipients, null: false, default: []
      t.boolean :include_with_disclosures, null: false, default: false
      t.timestamps
    end

    create_table :record_amendments do |t| # Solution 20
      t.references :amendment_request, null: false, foreign_key: true
      t.references :target, polymorphic: true, null: false
      t.references :author, foreign_key: { to_table: :users }
      t.string :kind, null: false
      t.text :body
      t.timestamps
    end

    create_table :communication_preferences do |t| # Solution 21
      t.references :patient, null: false, foreign_key: true
      t.string :channel, null: false
      t.text :destination
      t.boolean :confidential, null: false, default: false
      t.boolean :allow_message_preview, null: false, default: false
      t.timestamps
    end

    create_table :patient_authorizations do |t| # Solution 21
      t.references :patient, null: false, foreign_key: true
      t.string :recipient, null: false
      t.string :purpose, null: false
      t.text :information_scope
      t.datetime :signed_at, null: false
      t.date :expires_on
      t.text :expiration_event
      t.datetime :revoked_at
      t.timestamps
    end
  end
end
