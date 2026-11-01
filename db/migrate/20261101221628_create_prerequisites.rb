class CreatePrerequisites < ActiveRecord::Migration[8.1]
  def change
    create_table :prerequisites do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :required_subject, null: false, foreign_key: { to_table: :subjects }
      t.timestamps
    end
    add_index :prerequisites, %i[subject_id required_subject_id], unique: true
  end
end
