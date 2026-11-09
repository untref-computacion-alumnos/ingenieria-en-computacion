class AddStudyPlanToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :study_plan, foreign_key: true
  end
end
