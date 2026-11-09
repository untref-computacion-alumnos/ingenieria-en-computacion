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

    it "links to the password reset" do
      assert_select "a[href='#{new_user_password_path}']", text: I18n.t("devise.shared.links.forgot_your_password")
    end
  end

  describe "POST /users/sign_in" do
    let!(:user) { create(:user, email: "ana@example.com") }

    context "with the right credentials" do
      let!(:user) { create(:user, :with_study_plan, email: "ana@example.com") }

      before { post user_session_path, params: { user: { email: user.email, password: user.password } } }

      it "redirects after the login" do
        expect(response).to have_http_status(:see_other)
      end

      it "signs the user in" do
        follow_redirect!
        assert_select "form[action='#{destroy_user_session_path}']"
      end

      it "goes to the plans list" do
        expect(response).to redirect_to(study_plans_path)
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

  describe "messages" do
    let!(:user) { create(:user, email: "ana@example.com") }
    let(:invalid_message) do
      I18n.t("devise.failure.invalid", authentication_keys: User.human_attribute_name(:email))
    end

    it "explains a wrong password in an alert" do
      post user_session_path, params: { user: { email: user.email, password: "not-the-password" } }
      assert_select "[role='alert']", text: invalid_message
    end

    it "gives the same message for an email nobody registered" do
      post user_session_path, params: { user: { email: "nobody@example.com", password: "a-long-password" } }
      assert_select "[role='alert']", text: invalid_message
    end

    it "keeps the email the user typed after a failed login" do
      post user_session_path, params: { user: { email: user.email, password: "not-the-password" } }
      assert_select "input[name='user[email]'][value='#{user.email}']"
    end

    it "says that the user is signed in" do
      post user_session_path, params: { user: { email: user.email, password: user.password } }
      follow_redirect!
      assert_select "[role='status']", text: I18n.t("devise.sessions.signed_in")
    end

    it "says that the user is signed out" do
      sign_in user
      delete destroy_user_session_path
      follow_redirect!
      assert_select "[role='status']", text: I18n.t("devise.sessions.signed_out")
    end
  end
end
