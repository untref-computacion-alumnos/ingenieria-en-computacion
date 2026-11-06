# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Account navigation" do
  context "when nobody is signed in" do
    before { get root_path }

    it "offers to create an account" do
      assert_select "header nav a[href='#{new_user_registration_path}']", text: I18n.t("layouts.account.sign_up")
    end

    it "does not offer to sign out" do
      assert_select "form[action='#{destroy_user_session_path}']", count: 0
    end
  end

  context "when a user is signed in" do
    let(:user) { create(:user, email: "ana@example.com") }

    before do
      sign_in user
      get root_path
    end

    it "shows who is signed in" do
      assert_select "header nav", text: /ana@example\.com/
    end

    it "offers to sign out with a button that sends DELETE" do
      assert_select "form[action='#{destroy_user_session_path}'][method='post']" do
        assert_select "input[name='_method'][value='delete']"
        assert_select "button", text: I18n.t("layouts.account.sign_out")
      end
    end

    it "does not offer to create an account" do
      assert_select "a[href='#{new_user_registration_path}']", count: 0
    end
  end
end
