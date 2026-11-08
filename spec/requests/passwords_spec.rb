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

  describe "GET /users/password/edit" do
    context "with a token" do
      before { get edit_user_password_path(reset_password_token: "the-token") }

      it "responds successfully" do
        expect(response).to have_http_status(:ok)
      end

      it "submits the form with the method and the token" do
        assert_select "form[action='#{user_password_path}']" do
          assert_select "input[type='hidden'][name='_method'][value='put']"
          assert_select "input[type='hidden'][name='user[reset_password_token]'][value='the-token']"
        end
      end

      it "renders the new password and its confirmation" do
        assert_select "form[action='#{user_password_path}']" do
          assert_select "input[type='password'][name='user[password]'][autocomplete='new-password']"
          assert_select "input[type='password'][name='user[password_confirmation]'][autocomplete='new-password']"
        end
      end

      it "labels every field" do
        assert_select "label[for='user_password']", text: I18n.t("devise.passwords.edit.new_password")
        assert_select "label[for='user_password_confirmation']",
                      text: I18n.t("devise.passwords.edit.confirm_new_password")
      end

      it "says how long the password must be" do
        assert_select "#password_hint", text: /#{User.password_length.min}/
      end

      it "uses a titled page in Spanish" do
        assert_select "h1", text: I18n.t("devise.passwords.edit.change_your_password")
      end
    end

    context "without a token" do
      before { get edit_user_password_path }

      it "goes back to the login page" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "explains why in an alert" do
        follow_redirect!
        assert_select "[role='alert']", text: I18n.t("devise.passwords.no_token")
      end
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
