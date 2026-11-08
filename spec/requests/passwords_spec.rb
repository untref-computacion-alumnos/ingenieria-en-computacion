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

  describe "POST /users/password" do
    let!(:user) { create(:user, email: "ana@example.com") }
    let(:confirmation) { I18n.t("devise.passwords.send_paranoid_instructions") }

    def ask_for_a_reset(email)
      post user_password_path, params: { user: { email: email } }
    end

    context "with the email of a registered user" do
      it "redirects to the login page" do
        ask_for_a_reset(user.email)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "sends one mail" do
        expect { ask_for_a_reset(user.email) }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end

      it "addresses the mail to that user" do
        ask_for_a_reset(user.email)
        expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
      end

      it "shows the confirmation" do
        ask_for_a_reset(user.email)
        follow_redirect!
        assert_select "[role='status']", text: confirmation
      end

      it "stores a reset token on the user" do
        expect { ask_for_a_reset(user.email) }.to change { user.reload.reset_password_sent_at }.from(nil)
      end
    end

    context "with an email nobody registered" do
      it "redirects to the login page, like for a registered one" do
        ask_for_a_reset("nobody@example.com")
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows the same confirmation" do
        ask_for_a_reset("nobody@example.com")
        follow_redirect!
        assert_select "[role='status']", text: confirmation
      end

      it "sends no mail" do
        expect { ask_for_a_reset("nobody@example.com") }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end

    context "with the email in another letter case" do
      it "finds the user" do
        expect { ask_for_a_reset("ANA@Example.com") }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end
  end
end
