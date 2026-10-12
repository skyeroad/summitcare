# Evidence for information system activity review (Solution 17).
class CreateActivityReviewTables < ActiveRecord::Migration[8.0]
  def change
    create_table :anomaly_findings do |t|
      t.string :kind, null: false
      t.bigint :actor_id
      t.bigint :patient_id
      t.datetime :window_start, null: false
      t.jsonb :details, null: false, default: {}
      t.string :status, null: false, default: "open"
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.string :disposition
      t.timestamps
    end
    add_index :anomaly_findings, [:kind, :actor_id, :window_start]

    create_table :activity_reviews do |t|
      t.datetime :period_start, null: false
      t.datetime :period_end, null: false
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :completed_at
      t.text :summary
      t.timestamps
    end
  end
end
