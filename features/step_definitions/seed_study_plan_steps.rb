# frozen_string_literal: true

When("the seed data is loaded") do
  Rails.application.load_seed
end

When("the seed data is loaded twice") do
  2.times { Rails.application.load_seed }
end

Then("the career has a study plan for the current year") do
  expect(StudyPlan.current.career).to be_present
end

Then("every subject belongs to a year and a term") do
  expect(Subject.where(year: nil).or(Subject.where(term: nil))).to be_empty
end

Then("no subject is its own prerequisite") do
  expect(Prerequisite.where("subject_id = required_subject_id")).to be_empty
end

Then("no duplicate subjects exist") do
  duplicates = Subject.group(:study_plan_id, :code).having("COUNT(*) > 1").count
  expect(duplicates).to be_empty
end
