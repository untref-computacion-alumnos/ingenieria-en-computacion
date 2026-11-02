# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Study plans" do
  describe "GET /study_plans" do
    it "lists the plans newest first" do
      create(:study_plan, year: 2013)
      create(:study_plan, year: 2022)
      get study_plans_path
      expect(response.body).to match(/2022.*2013/m)
    end

    it "shows how many subjects each plan has" do
      create_list(:subject, 3, study_plan: create(:study_plan, year: 2013))
      create_list(:subject, 5, study_plan: create(:study_plan, year: 2022))
      get study_plans_path
      expect(response.body).to include(I18n.t("study_plans.card.subjects",
                                              count: 3)).and include(I18n.t("study_plans.card.subjects", count: 5))
    end
  end
end
