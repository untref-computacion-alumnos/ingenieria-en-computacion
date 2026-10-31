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

    it "uses the application name as the page title" do
      expect(response.body).to include("<title>#{I18n.t("app.name")}</title>")
    end
  end
end
