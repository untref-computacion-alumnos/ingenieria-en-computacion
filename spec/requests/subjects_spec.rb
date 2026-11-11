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

    it "lists the prerequisites as links to their own detail" do
      required = create(:subject, study_plan: plan, name: "Álgebra I")
      create(:prerequisite, subject: subject_record, required_subject: required)
      get subject_path(subject_record)
      assert_select "h3", text: I18n.t("subjects.detail.prerequisites")
      assert_select "li a[href=?]", subject_path(required), text: "Álgebra I"
    end

    it "says so when the subject has no prerequisites" do
      get subject_path(subject_record)
      expect(response.body).to include(I18n.t("subjects.detail.no_prerequisites"))
    end

    it "is wrapped in the subject_detail Turbo Frame so it can open in the side panel" do
      get subject_path(subject_record)
      assert_select "turbo-frame#subject_detail"
    end

    it "links back to the plan out of the frame" do
      get subject_path(subject_record)
      assert_select "a[href=?][data-turbo-frame=_top]", study_plan_path(plan)
    end

    describe "status picker" do
      it "is shown to a visitor, with nothing pressed" do
        get subject_path(subject_record)
        assert_select "section#status_picker_subject_#{subject_record.id}"
        assert_select "button[aria-pressed='true']", count: 0
      end

      it "shows the status the signed-in student marked as pressed" do
        user = create(:user, :with_study_plan)
        create(:subject_progress, user: user, subject: subject_record, status: :approved)
        sign_in user
        get subject_path(subject_record)
        assert_select "button[aria-pressed='true']", text: /#{I18n.t("subject_progresses.statuses.approved")}/
      end

      it "shows pending to a student who never marked the subject" do
        sign_in create(:user, :with_study_plan)
        get subject_path(subject_record)
        assert_select "button[aria-pressed='true']", text: /#{I18n.t("subject_progresses.statuses.pending")}/
      end
    end

    context "when a prerequisite is missing" do
      let(:plan) { create(:study_plan) }
      let(:required) { create(:subject, study_plan: plan, name: "Álgebra") }
      let(:geometry) { create(:subject, study_plan: plan, name: "Geometría") }

      before { create(:prerequisite, subject: geometry, required_subject: required) }

      it "lists it to a student who has not passed it" do
        sign_in create(:user, study_plan: plan)
        get subject_path(geometry)
        assert_select "[role='note'] a", text: "Álgebra"
      end

      it "does not list it once the student passed it" do
        user = create(:user, study_plan: plan)
        create(:subject_progress, user: user, subject: required, status: :regular)
        sign_in user
        get subject_path(geometry)
        assert_select "[role='note']", count: 0
      end

      it "does not list it to a visitor" do
        get subject_path(geometry)
        assert_select "[role='note']", count: 0
      end
    end
  end
end
