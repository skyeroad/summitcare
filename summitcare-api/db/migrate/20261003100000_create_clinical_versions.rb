class CreateClinicalVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :clinical_versions do |t|
      t.string   :item_type, null: false
      t.bigint   :item_id, null: false
      t.string   :event, null: false
      t.string   :whodunnit
      t.string   :request_id
      t.text     :object          # encrypted, so text rather than jsonb
      t.text     :object_changes  # encrypted
      t.datetime :created_at, null: false
    end
    add_index :clinical_versions, [:item_type, :item_id]
  end
end
