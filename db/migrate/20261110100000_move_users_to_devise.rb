# Moves users from the Rails 8 authentication generator to Devise. has_secure_password
# and Devise both store bcrypt hashes, so existing passwords keep working.
class MoveUsersToDevise < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :email_address, :email
    rename_column :users, :password_digest, :encrypted_password
    change_column_default :users, :encrypted_password, from: nil, to: ""

    change_table :users, bulk: true do |t|
      # Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      # Rememberable
      t.datetime :remember_created_at

      # Confirmable (confirmed_at already exists)
      t.string :confirmation_token
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email

      t.index :reset_password_token, unique: true
      t.index :confirmation_token, unique: true
    end

    # Devise keeps sessions in the signed cookie, so the database sessions table goes.
    drop_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
