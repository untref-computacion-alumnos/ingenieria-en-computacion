# frozen_string_literal: true

Given("I am signed in as a student without a plan") do
  @student = create(:user)
  log_in_with(@student.email, VALID_PASSWORD)
end

When("I choose the plan {string}") do |year|
  visit edit_users_study_plan_path
  choose I18n.t("study_plans.card.title", year: year)
  click_button I18n.t("users.study_plans.edit.submit")
end

Then("I should be asked to choose my study plan") do
  expect(page).to have_current_path(edit_users_study_plan_path)
  expect(page).to have_css("h1", text: I18n.t("users.study_plans.edit.title"))
end

Then("my plan should be {string}") do |year|
  expect(@student.reload.study_plan.year).to eq(year.to_i)
end

Then("I should see the grid of {string}") do |year|
  expect(page).to have_css("h1", text: I18n.t("study_plans.show.title", year: year))
end
