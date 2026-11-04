# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Subjects" do
  describe "GET /subjects/:id" do
    let(:plan) { create(:study_plan, year: 2022) }
    let(:subject_record) do
      create(:subject, study_plan: plan, name: "Álgebra II", code: "AL2", year: 2, term: 1, hours: 96, credits: 6)
    end

    it "shows the name, code, position, hours and credits" do
      get subject_path(subject_record)
      expect(response.body).to include("Álgebra II", "AL2", "96", "6")
        .and include(I18n.t("subjects.detail.position", year: 2, term: 1))
    end

    it "responds with not found for an unknown subject" do
      get subject_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end
