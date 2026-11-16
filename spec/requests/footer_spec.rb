# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Footer" do
  [
    ["the home page", -> { root_path }],
    ["the sign-up page", -> { new_user_registration_path }],
    ["the terms page", -> { terms_path }]
  ].each do |name, path|
    context "with #{name}" do
      before { get instance_exec(&path) }

      it "links to the privacy notice" do
        assert_select "footer nav a[href='#{privacy_path}']", text: I18n.t("layouts.footer.privacy")
      end

      it "links to the terms" do
        assert_select "footer nav a[href='#{terms_path}']", text: I18n.t("layouts.footer.terms")
      end

      it "labels the navigation for screen readers" do
        assert_select "footer nav[aria-label='#{I18n.t("layouts.footer.label")}']"
      end
    end
  end
end
