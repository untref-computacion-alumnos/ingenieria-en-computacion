class CreateSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :subjects do |t|
      t.references :study_plan, null: false, foreign_key: true
      t.string :code, null: false
      t.string :name, null: false
      t.integer :year, null: false
      t.integer :term, null: false
      t.integer :hours
      t.integer :credits
      t.timestamps
    end
    add_index :subjects, %i[study_plan_id code], unique: true
  end
end
