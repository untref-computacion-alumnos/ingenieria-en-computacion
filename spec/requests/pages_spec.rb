# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pages" do
  shared_examples "a public legal page" do |path:, scope:, sections:|
    context "when nobody is signed in" do
      before { get path }

      it "responds successfully" do
        expect(response).to have_http_status(:ok)
      end

      it "has a titled page" do
        assert_select "main h1", text: I18n.t("#{scope}.title")
      end

      it "uses the title as the browser title" do
        expect(response.body).to include("<title>#{I18n.t("#{scope}.title")}</title>")
      end

      it "has a section of each topic" do
        sections.each do |key|
          assert_select "main section h2", text: I18n.t("#{scope}.#{key}.title")
        end
      end
    end

    it "is shown to a signed-in user who has not chosen a study plan" do
      sign_in create(:user)
      get path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /privacy" do
    it_behaves_like "a public legal page", path: "/privacy", scope: "pages.privacy",
                                           sections: %w[data use progress rights]

    it "says that the progress is private by default" do
      get privacy_path
      expect(response.body).to include(I18n.t("pages.privacy.progress.body"))
    end

    it "announces that exporting and deleting the data is coming" do
      get privacy_path
      expect(response.body).to include(I18n.t("pages.privacy.rights.body"))
    end
  end

  describe "GET /terms" do
    it_behaves_like "a public legal page", path: "/terms", scope: "pages.terms", sections: %w[use account changes]
  end
end
