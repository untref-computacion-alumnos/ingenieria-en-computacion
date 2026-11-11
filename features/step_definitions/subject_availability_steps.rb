# frozen_string_literal: true

Given("the subject {string} of the plan requires {string}") do |name, required_name|
  @required = Subject.find_by!(name: required_name)
  subject = create(:subject, study_plan: @plan, name: name, year: 2)
  create(:prerequisite, subject: subject, required_subject: @required)
end

When("I look at the grid") do
  visit study_plan_path(@plan)
end

Then("I should see which prerequisites are missing") do
  expect(page).to have_text(I18n.t("subject_progresses.picker.missing"))
  expect(page).to have_link(@required.name)
end
