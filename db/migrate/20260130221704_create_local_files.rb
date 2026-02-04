class CreateLocalFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :local_files do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :folder_path

      t.timestamps
    end
  end
end
