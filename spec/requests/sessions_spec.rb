# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions" do
  describe "GET /users/sign_in" do
    before { get new_user_session_path }

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the form with the email and the password" do
      assert_select "form[action='#{user_session_path}']" do
        assert_select "input[type='email'][name='user[email]'][autocomplete='email']"
        assert_select "input[type='password'][name='user[password]'][autocomplete='current-password']"
      end
    end

    it "labels every field" do
      assert_select "label[for='user_email']", text: User.human_attribute_name(:email)
      assert_select "label[for='user_password']", text: User.human_attribute_name(:password)
      assert_select "label[for='user_remember_me']", text: User.human_attribute_name(:remember_me)
    end

    it "uses a titled page in Spanish" do
      assert_select "h1", text: I18n.t("devise.sessions.new.sign_in")
    end
  end

  describe "POST /users/sign_in" do
    let!(:user) { create(:user, email: "ana@example.com") }

    context "with the right credentials" do
      before { post user_session_path, params: { user: { email: user.email, password: user.password } } }

      it "redirects after the login" do
        expect(response).to have_http_status(:see_other)
      end

      it "signs the user in" do
        follow_redirect!
        assert_select "form[action='#{destroy_user_session_path}']"
      end
    end

    context "with a wrong password" do
      before { post user_session_path, params: { user: { email: user.email, password: "not-the-password" } } }

      it "renders the form again with an error status" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not sign the user in" do
        get root_path
        assert_select "form[action='#{destroy_user_session_path}']", count: 0
      end
    end

    context "with an email nobody registered" do
      before { post user_session_path, params: { user: { email: "nobody@example.com", password: "a-long-password" } } }

      it "renders the form again with an error status" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
