class AddGradeAndDateToSubjectProgresses < ActiveRecord::Migration[8.1]
  def change
    change_table :subject_progresses, bulk: true do |t|
      t.decimal :grade, precision: 3, scale: 1
      t.date :approved_on
      t.boolean :final_exam_taken, null: false, default: false
    end
  end
end
