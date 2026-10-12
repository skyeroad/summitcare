# Cookie sessions for the staff console (Solutions 1 and 5).
class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.datetime :last_active_at
      t.timestamps
    end
  end
end
