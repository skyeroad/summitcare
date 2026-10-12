# Rails 8 authentication generator's users table, extended for MFA and passkeys
# (Solution 1). Users are never deleted: set deactivated_at instead.
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "patient"
      t.text :otp_secret # encrypted
      t.datetime :otp_enabled_at
      t.datetime :otp_last_used_at
      t.string :webauthn_id
      t.datetime :last_sign_in_at
      t.datetime :deactivated_at
      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_index :users, :webauthn_id, unique: true
  end
end
