# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Passwords" do
  describe "GET /users/password/new" do
    before { get new_user_password_path }

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the form with the email" do
      assert_select "form[action='#{user_password_path}'][method='post']" do
        assert_select "input[type='email'][name='user[email]'][autocomplete='email']"
      end
    end

    it "labels the field" do
      assert_select "label[for='user_email']", text: User.human_attribute_name(:email)
    end

    it "uses a titled page in spanish" do
      assert_select "h1", text: I18n.t("devise.passwords.new.forgot_your_password")
    end
  end

  describe "GET /users/password/new when a user is signed in" do
    it "sends them away: there is nothing to recover" do
      sign_in create(:user)
      get new_user_password_path
      expect(response).to have_http_status(:found)
    end
  end
end
