# frozen_string_literal: true

Given("the subject {string} requires {string}") do |name, required_name|
  plan = create(:study_plan)
  required = create(:subject, study_plan: plan, name: required_name)
  @subject = create(:subject, study_plan: plan, name: name, year: 2, term: 1, hours: 96, credits: 6)
  create(:prerequisite, subject: @subject, required_subject: required)
end

When("I open the subject {string} from the grid") do |name|
  visit study_plan_path(@subject.study_plan)
  click_link name
end

Then("I should see the subject details") do
  panel = find_by_id("subject_detail")
  expect(panel).to have_text(@subject.name)
  expect(panel).to have_text(@subject.code)
  expect(panel).to have_text(I18n.t("subjects.detail.position", year: 2, term: 1))
end

Then("I should see {string} listed as a prerequisite") do |name|
  within("#subject_detail") do
    expect(page).to have_css("h3", text: I18n.t("subjects.detail.prerequisites"))
    expect(page).to have_link(name)
  end
end

When("I open a subject that does not exist") do
  visit subject_path(id: 0)
end
