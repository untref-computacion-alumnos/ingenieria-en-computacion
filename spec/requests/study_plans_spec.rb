# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Study plans" do
  describe "GET /study_plans" do
    let(:active_label) { I18n.t("study_plans.card.active") }

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

    it "marks only the newest plan as the active one" do
      create(:study_plan, year: 2013)
      create(:study_plan, year: 2022)
      get study_plans_path
      assert_select "li", text: /2022.*#{active_label}/m, count: 1
      assert_select "li", text: /#{active_label}/, count: 1
    end

    it "links each plan to its grid" do
      plan = create(:study_plan, year: 2022)
      get study_plans_path
      assert_select "li a[href=?]", study_plan_path(plan)
    end
  end

  describe "GET /study_plans/:id" do
    def term_heading(year, term)
      I18n.t("study_plans.grid.term", year: year, term: term)
    end

    it "shows the plan year and its subjects" do
      plan = create(:study_plan, year: 2022)
      create(:subject, study_plan: plan, name: "Álgebra I")
      get study_plan_path(plan)
      expect(response.body).to include("Álgebra I").and include(I18n.t("study_plans.show.title", year: 2022))
    end

    it "does not show the subjects of other plans" do
      create(:subject, study_plan: create(:study_plan, year: 2013), name: "Old subject")
      get study_plan_path(create(:study_plan, year: 2022))
      expect(response.body).not_to include("Old subject")
    end

    it "responds with not found for an unknown plan" do
      get study_plan_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end

    context "with subjects in several terms" do
      let(:plan) { create(:study_plan, year: 2022) }
      let(:expected_order) do
        [term_heading(1, 1), "Álgebra I", term_heading(1, 2), "Álgebra II", term_heading(2, 1), "Física I"]
      end

      before do
        create(:subject, study_plan: plan, name: "Física I", year: 2, term: 1)
        create(:subject, study_plan: plan, name: "Álgebra II", year: 1, term: 2)
        create(:subject, study_plan: plan, name: "Álgebra I", year: 1, term: 1)
      end

      it "groups the subjects by year and term, in order" do
        get study_plan_path(plan)
        expect(response.body).to match(Regexp.new(expected_order.join(".*"), Regexp::MULTILINE))
      end
    end
  end
end
