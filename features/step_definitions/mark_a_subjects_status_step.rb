# frozen_string_literal: true

def status_label(status)
  I18n.t("subject_progresses.statuses.#{status}")
end

def mark_subject(name, status)
  visit study_plan_path(@plan)
  click_link name
  click_button status_label(status)
end

Given("the study plan {string} has the subject {string}") do |year, name|
  @plan = create(:study_plan, year: year.to_i)
  create(:subject, study_plan: @plan, name: name)
end

Given("I am signed in as a student following the plan {string}") do |year|
  @student = create(:user, study_plan: StudyPlan.find_by!(year: year.to_i))
  log_in_with(@student.email, VALID_PASSWORD)
end

Given("I marked the subject {string} as {status}") do |name, status|
  create(:subject_progress, user: @student, subject: Subject.find_by!(name: name), status: status)
end

Given("I opened the subject {string} from the grid") do |name|
  visit study_plan_path(@plan)
  click_link name
  expect(page).to have_css("#subject_detail", text: name)
  page.execute_script("window.sameDocument = true")
end

When("I mark the subject {string} as {status}") do |name, status|
  mark_subject(name, status)
end

When("I try to mark the subject {string} as {status}") do |name, status|
  mark_subject(name, status)
end

When("I set the subject as {status}") do |status|
  within("#subject_detail") { click_button status_label(status) }
end

Then("the subject {string} should show as {status}") do |name, status|
  visit study_plan_path(@plan)
  expect(find("a", text: name)).to have_css("[data-status='#{status}']", text: status_label(status))
end

Then("the card of {string} should show as {status}") do |name, status|
  expect(find("a", text: name)).to have_css("[data-status='#{status}']", text: status_label(status))
end

Then("the page should not have been reloaded") do
  expect(page.evaluate_script("window.sameDocument")).to be(true)
end

Then("I should be asked to sign in") do
  expect(page).to have_current_path(new_user_session_path)
  expect(page).to have_text(I18n.t("devise.failure.unauthenticated"))
end
