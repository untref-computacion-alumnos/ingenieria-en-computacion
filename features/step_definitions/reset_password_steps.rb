# frozen_string_literal: true

NEW_PASSWORD = "another-long-password"

def ask_for_a_reset(email)
  visit new_user_password_path
  fill_in User.human_attribute_name(:email), with: email
  click_button I18n.t("devise.passwords.new.send_me_reset_password_instructions")
end

Given("a registered student with a reset link") do
  @student = create(:user, email: "ana@example.com")
  @student.send_reset_password_instructions
  mail = ActionMailer::Base.deliveries.last
  @reset_path = URI(mail.body.decoded[/href="([^"]+)"/, 1]).request_uri
end

When("I request a password reset for their email") do
  ask_for_a_reset(@student.email)
end

When("I request a password reset for an unknown email") do
  ask_for_a_reset("nobody@example.com")
end

When("I follow the link and set a new password") do
  visit @reset_path
  fill_in I18n.t("devise.passwords.edit.new_password"), with: NEW_PASSWORD, match: :prefer_exact
  fill_in I18n.t("devise.passwords.edit.confirm_new_password"), with: NEW_PASSWORD
  click_button I18n.t("devise.passwords.edit.change_my_password")
end

Then("a reset email should be sent to them") do
  expect(ActionMailer::Base.deliveries.size).to eq(1)
  expect(ActionMailer::Base.deliveries.last.to).to eq([@student.email])
end

Then("I should be able to log in with the new password") do
  click_button I18n.t("layouts.account.sign_out")
  log_in_with(@student.email, NEW_PASSWORD)
  expect(page).to have_button(I18n.t("layouts.account.sign_out"))
end

Then("I should see the same confirmation message") do
  expect(page).to have_text(I18n.t("devise.passwords.send_paranoid_instructions"))
end

Then("no email should be sent") do
  expect(ActionMailer::Base.deliveries).to be_empty
end
