# frozen_string_literal: true

When("I visit the home page") do
  visit root_path
end

Then("I should see the application name") do
  expect(page).to have_text(I18n.t("app.name"))
end

Then("I should see the home tagline") do
  expect(page).to have_text(I18n.t("home.tagline"))
end
