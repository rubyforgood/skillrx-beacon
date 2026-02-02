class CreateUserActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :user_activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_type
      t.references :topic, null: true, foreign_key: true
      t.string :file_type
      t.string :search_term
      t.boolean :search_found
      t.string :os
      t.string :browser
      t.string :ip_address

      t.timestamps
    end
  end
end
