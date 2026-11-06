# frozen_string_literal: true

VALID_PASSWORD = "a-long-password"

def sign_up_with(email, password: VALID_PASSWORD)
  visit new_user_registration_path
  fill_in User.human_attribute_name(:email), with: email
  fill_in User.human_attribute_name(:password), with: password, match: :prefer_exact
  fill_in User.human_attribute_name(:password_confirmation), with: password
  click_button I18n.t("devise.registrations.new.sign_up")
end

Given("a user exists with the email {string}") do |email|
  create(:user, email: email)
end

When("I sign up with a valid email and password") do
  sign_up_with("ana@example.com")
end

When("I sign up with the email {string}") do |email|
  sign_up_with(email)
end

Then("I should be signed in") do
  expect(page).to have_button(I18n.t("layouts.account.sign_out"))
end

Then("I should have the student role") do
  expect(User.find_by!(email: "ana@example.com")).to have_role(:student)
end

Then("I should see an error about the email being taken") do
  expect(page).to have_text(I18n.t("errors.messages.taken"))
end

Then("I should not be signed in") do
  expect(page).to have_no_button(I18n.t("layouts.account.sign_out"))
end
