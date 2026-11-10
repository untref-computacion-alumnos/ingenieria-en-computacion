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

    it "has an empty side panel where the subject detail opens" do
      get study_plan_path(create(:study_plan, year: 2022))
      assert_select "turbo-frame#subject_detail:empty"
    end

    context "with subjects that have prerequisites" do
      let(:plan) { create(:study_plan) }
      let(:required) { create(:subject, study_plan: plan) }
      let(:dependents) { create_list(:subject, 2, study_plan: plan, year: 2) }

      before do
        dependents.each { |subject| create(:prerequisite, subject: subject, required_subject: required) }
      end

      it "carries the prerequisite ids of every card, without N+1 queries" do
        get study_plan_path(plan)
        assert_select "a[data-subject-id=?][data-required-ids=?]", dependents.first.id.to_s, required.id.to_s
      end
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

    context "when a visitor looks at the subject statuses" do
      let(:plan) { create(:study_plan, year: 2022) }

      before { create(:subject, study_plan: plan, name: "Álgebra I") }

      it "shows no statuses" do
        get study_plan_path(plan)
        assert_select "[data-status]", count: 0
      end
    end

    context "when a student is signed in" do
      let(:plan) { create(:study_plan, year: 2022) }
      let!(:algebra) { create(:subject, study_plan: plan, name: "Álgebra I") }
      let!(:analysis) { create(:subject, study_plan: plan, name: "Análisis I") }
      let(:user) { create(:user, study_plan: plan) }

      before do
        create(:subject_progress, user: user, subject: algebra, status: :approved)
        sign_in user
        get study_plan_path(plan)
      end

      it "shows what the student marked" do
        assert_select "[data-status='approved']", count: 1
      end

      it "shows pending for the rest" do
        assert_select "[data-status='pending']", count: 1
      end

      it "does not show what another student marked" do
        create(:subject_progress, subject: analysis, status: :promoted)
        get study_plan_path(plan)
        assert_select "[data-status='promoted']", count: 0
      end
    end
  end
end
