class CreateSubjectProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :subject_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :subject_progresses, %i[user_id subject_id], unique: true
  end
end
