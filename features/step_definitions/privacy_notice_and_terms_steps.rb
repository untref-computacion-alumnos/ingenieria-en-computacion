# frozen_string_literal: true

When("I visit the privacy page") do
  visit privacy_path
end

When("I visit the terms page") do
  visit terms_path
end

When("I sign up without accepting the terms") do
  sign_up_with("ana@example.com", accept_terms: false)
end

Then("I should see the privacy notice") do
  expect(page).to have_css("main h1", text: I18n.t("pages.privacy.title"))
end

Then("I should see the terms") do
  expect(page).to have_css("main h1", text: I18n.t("pages.terms.title"))
end

Then("I should see an error about accepting the terms") do
  expect(page).to have_text(I18n.t("errors.messages.accepted"))
end
