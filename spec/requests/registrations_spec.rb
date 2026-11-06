# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations" do
  let(:valid_params) do
    { user: { email: "ana@example.com", password: "a-long-password", password_confirmation: "a-long-password" } }
  end

  describe "GET /users/sign_up" do
    before { get new_user_registration_path }

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the form with the email and both password fields" do
      assert_select "form[action='#{user_registration_path}']" do
        assert_select "input[type='email'][name='user[email]'][autocomplete='email']"
        assert_select "input[type='password'][name='user[password]'][autocomplete='new-password']"
        assert_select "input[type='password'][name='user[password_confirmation]'][autocomplete='new-password']"
      end
    end

    it "labels every field" do
      assert_select "label[for='user_email']", text: User.human_attribute_name(:email)
      assert_select "label[for='user_password']", text: User.human_attribute_name(:password)
      assert_select "label[for='user_password_confirmation']",
                    text: User.human_attribute_name(:password_confirmation)
    end

    it "tells the minimum password length" do
      expect(response.body).to include(I18n.t("devise.shared.minimum_password_length", count: 10))
    end

    it "uses a titled page in Spanish" do
      assert_select "h1", text: I18n.t("devise.registrations.new.sign_up")
    end
  end

  describe "POST /users" do
    context "with valid data" do
      it "creates the user" do
        expect { post user_registration_path, params: valid_params }.to change(User, :count).by(1)
      end

      it "signs the user in and goes back to the home page" do
        post user_registration_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "gives the new user the student role" do
        post user_registration_path, params: valid_params
        expect(User.find_by!(email: "ana@example.com")).to have_role(:student)
      end
    end

    context "with an email that is already taken" do
      before { create(:user, email: "ana@example.com") }

      it "does not create a user" do
        expect { post user_registration_path, params: valid_params }.not_to change(User, :count)
      end

      it "renders the form again with an error status" do
        post user_registration_path, params: valid_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "explains that the email is taken" do
        post user_registration_path, params: valid_params
        expect(response.body).to include(I18n.t("errors.messages.taken"))
      end
    end

    context "with a short password" do
      let(:params) { { user: { email: "ana@example.com", password: "short", password_confirmation: "short" } } }

      it "does not create a user" do
        expect { post user_registration_path, params: params }.not_to change(User, :count)
      end

      it "renders the form again with an error status" do
        post user_registration_path, params: params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when the confirmation does not match" do
      let(:params) do
        { user: { email: "ana@example.com", password: "a-long-password", password_confirmation: "another-one-0" } }
      end

      it "does not create a user" do
        expect { post user_registration_path, params: params }.not_to change(User, :count)
      end

      it "renders the form again with an error status" do
        post user_registration_path, params: params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
