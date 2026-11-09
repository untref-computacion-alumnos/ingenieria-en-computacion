# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home" do
  describe "GET /" do
    before { get root_path }

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "shows the application name" do
      expect(response.body).to include(I18n.t("app.name"))
    end

    it "shows the tagline" do
      expect(response.body).to include(I18n.t("home.tagline"))
    end

    it "declares the page language" do
      expect(response.body).to include('lang="es-AR"')
    end

    it "lets keyboard users skip to the main content" do
      assert_select "a[href='#main']", text: I18n.t("app.skip_to_content")
      assert_select "main#main"
    end

    it "supports the light and the dark color scheme" do
      assert_select "meta[name='color-scheme'][content='light dark']"
    end

    it "uses the application name as the page title" do
      expect(response.body).to include("<title>#{I18n.t("app.name")}</title>")
    end

    describe "GET / for a signed-in user" do
      it "sends a user without a study plan to the picker" do
        sign_in create(:user)
        get root_path
        expect(response).to redirect_to(edit_users_study_plan_path)
      end

      it "shows the home page to a user who follows a plan" do
        sign_in create(:user, :with_study_plan)
        get root_path
        expect(response).to have_http_status(:ok)
      end

      it "shows the home page to a visitor" do
        get root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
