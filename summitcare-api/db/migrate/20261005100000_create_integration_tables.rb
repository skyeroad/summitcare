# Analytics counts (Solution 26) and partner integrations (Solution 27).
class CreateIntegrationTables < ActiveRecord::Migration[8.0]
  def change
    create_table :analytics_daily_counts do |t|
      t.date :day, null: false
      t.string :event, null: false
      t.integer :total, null: false, default: 0
      t.timestamps
    end
    add_index :analytics_daily_counts, [:day, :event], unique: true

    create_table :partners do |t|
      t.string :name, null: false
      t.string :relationship, null: false
      t.string :vendor_key
      t.text :webhook_secret # encrypted
      t.timestamps
    end

    create_table :partner_credentials do |t|
      t.references :partner, null: false, foreign_key: true
      t.string :lookup_id, null: false
      t.string :secret_digest, null: false
      t.string :scopes, array: true, null: false, default: []
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :partner_credentials, :lookup_id, unique: true

    create_table :webhook_receipts do |t|
      t.references :partner, null: false, foreign_key: true
      t.string :event_id, null: false
      t.timestamps
    end
    add_index :webhook_receipts, [:partner_id, :event_id], unique: true
  end
end
