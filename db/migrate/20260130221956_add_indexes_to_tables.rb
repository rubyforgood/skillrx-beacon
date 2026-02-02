class AddIndexesToTables < ActiveRecord::Migration[8.1]
  def change
    add_index :topics, [ :year, :month ]
    add_index :topics, :view_count
    add_index :topics, :topic_external_id
    add_index :user_activity_logs, :action_type
    add_index :admin_activity_logs, :action_type
  end
end
