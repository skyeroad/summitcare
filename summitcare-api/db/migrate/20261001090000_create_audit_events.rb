class CreateAuditEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_events do |t|
      t.datetime :occurred_at, null: false
      t.bigint   :actor_id
      t.string   :actor_role
      t.string   :action, null: false
      t.string   :subject_type
      t.bigint   :subject_id
      t.bigint   :patient_id
      t.inet     :ip_address
      t.string   :user_agent
      t.string   :request_id
      t.bigint   :device_session_id
      t.text     :reason
      t.jsonb    :metadata, null: false, default: {}
      t.string   :previous_digest # Solution 14
      t.string   :digest          # Solution 14
    end
    add_index :audit_events, [:patient_id, :occurred_at]
    add_index :audit_events, [:actor_id, :occurred_at]
  end
end
