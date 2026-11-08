# frozen_string_literal: true

require "rails_helper"

RSpec.describe Devise::Mailer do
  describe "#reset_password_instructions" do
    let(:user) { create(:user, email: "ana@example.com") }
    let(:mail) { described_class.reset_password_instructions(user, "the-token") }

    it "is addressed to the user" do
      expect(mail.to).to eq(["ana@example.com"])
    end

    it "comes from the configured sender" do
      expect(mail.from).to eq([Devise.mailer_sender])
    end

    it "does not use the placeholder sender" do
      expect(Devise.mailer_sender).not_to include("please-change-me")
    end

    it "has a subject in Spanish" do
      expect(mail.subject).to eq(I18n.t("devise.mailer.reset_password_instructions.subject"))
    end

    it "greets the user and explains what to do, in Spanish" do
      expect(mail.body.decoded).to include(
        I18n.t("devise.mailer.reset_password_instructions.greeting", recipient: "ana@example.com"),
        I18n.t("devise.mailer.reset_password_instructions.action")
      )
    end

    it "links to the page where the new password is chosen" do
      expect(mail.body.decoded).to include(edit_user_password_url(reset_password_token: "the-token"))
    end
  end
end
