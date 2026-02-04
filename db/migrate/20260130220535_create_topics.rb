class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :topics do |t|
      t.references :content_provider, null: false, foreign_key: true
      t.integer :year
      t.string :month
      t.string :title
      t.string :volume
      t.string :issue
      t.integer :view_count, default: 0
      t.string :topic_external_id

      t.timestamps
    end
  end
end
