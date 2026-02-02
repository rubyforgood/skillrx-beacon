class CreateAdminActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_activity_logs do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :action_type
      t.text :details
      t.string :os
      t.string :browser
      t.string :ip_address

      t.timestamps
    end
  end
end
