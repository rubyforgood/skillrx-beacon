class CreateTopicAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :topic_authors do |t|
      t.references :topic, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end
  end
end
