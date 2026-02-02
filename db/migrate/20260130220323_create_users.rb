class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :login_id
      t.integer :login_count, default: 0

      t.timestamps
    end
    add_index :users, :login_id, unique: true
  end
end
