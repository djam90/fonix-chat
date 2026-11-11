class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :room, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true, index: false
      t.text :body, null: false

      t.timestamps
    end
    # The composite indexes also cover lookups by room_id or user_id alone.
    add_index :messages, :created_at
    add_index :messages, [ :room_id, :created_at ]
    add_index :messages, [ :user_id, :created_at ]
  end
end
