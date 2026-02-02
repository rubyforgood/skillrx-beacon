class CreateAdmins < ActiveRecord::Migration[8.1]
  def change
    create_table :admins do |t|
      t.string :first_name
      t.string :last_name
      t.string :login_id
      t.string :password_digest

      t.timestamps
    end
    add_index :admins, :login_id, unique: true
  end
end
