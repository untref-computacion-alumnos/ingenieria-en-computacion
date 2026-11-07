# frozen_string_literal: true

def log_in_with(email, password)
  visit new_user_session_path
  fill_in User.human_attribute_name(:email), with: email
  fill_in User.human_attribute_name(:password), with: password
  click_button I18n.t("devise.sessions.new.sign_in")
end

Given("a registered student") do
  @student = create(:user, email: "ana@example.com")
end

Given("I am signed in as a student") do
  log_in_with(create(:user).email, VALID_PASSWORD)
end

When("I log in with the right credentials") do
  log_in_with(@student.email, VALID_PASSWORD)
end

When("I log in with a wrong password") do
  log_in_with(@student.email, "not-the-pasword")
end

When("I log out") do
  click_button I18n.t("layouts.account.sign_out")
end

Then("I should see the invalid credentials message") do
  message = I18n.t("devise.failure.invalid", authentication_keys: User.human_attribute_name(:email))
  expect(page).to have_text(message)
end
