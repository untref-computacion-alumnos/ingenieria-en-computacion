class CreateStudyPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :study_plans do |t|
      t.references :career, null: false, foreign_key: true
      t.integer :year, null: false
      t.timestamps
    end
  end
end
