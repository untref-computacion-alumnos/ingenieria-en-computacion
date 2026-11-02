class AddUniqueYearIndexToStudyPlans < ActiveRecord::Migration[8.1]
  def change
    add_index :study_plans, %i[career_id year], unique: true
  end
end
