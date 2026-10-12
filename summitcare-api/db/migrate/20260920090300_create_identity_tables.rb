# Mobile device sessions (Solution 3), passkeys and recovery codes (Solution 1).
class CreateIdentityTables < ActiveRecord::Migration[8.0]
  def change
    create_table :device_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :device_id, null: false
      t.string :device_name
      t.string :access_token_digest
      t.string :refresh_token_digest
      t.string :previous_refresh_token_digest
      t.datetime :access_expires_at
      t.datetime :refresh_expires_at, null: false
      t.datetime :last_seen_at
      t.datetime :revoked_at
      t.string :revoked_reason
      t.timestamps
    end
    add_index :device_sessions, :access_token_digest, unique: true
    add_index :device_sessions, :refresh_token_digest, unique: true
    add_index :device_sessions, :previous_refresh_token_digest

    create_table :webauthn_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.bigint :sign_count, null: false, default: 0
      t.string :nickname
      t.timestamps
    end
    add_index :webauthn_credentials, :external_id, unique: true

    create_table :recovery_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code_digest, null: false
      t.datetime :used_at
      t.timestamps
    end
    add_index :recovery_codes, [:user_id, :code_digest]
  end
end
