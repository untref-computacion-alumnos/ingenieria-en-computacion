# frozen_string_literal: true

Given("the study plans {string} and {string} exist") do |first_year, second_year|
  create(:study_plan, year: first_year.to_i)
  create(:study_plan, year: second_year.to_i)
end

When("I visit the study plans page") do
  visit study_plans_path
end

Then("I should see the plans {string} and {string} in that order") do |first_year, second_year|
  titles = [first_year, second_year].map { |year| I18n.t("study_plans.card.title", year: year) }
  expect(page.text).to match(/#{Regexp.escape(titles.first)}.*#{Regexp.escape(titles.last)}/m)
end

Then("the plan {string} should be marked as the active plan") do |year|
  card = find("li", text: I18n.t("study_plans.card.title", year: year))
  expect(card).to have_text(I18n.t("study_plans.card.active"))
end
