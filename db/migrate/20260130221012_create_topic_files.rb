class CreateTopicFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :topic_files do |t|
      t.references :topic, null: false, foreign_key: true
      t.string :filename
      t.integer :file_size
      t.string :file_type

      t.timestamps
    end
  end
end
