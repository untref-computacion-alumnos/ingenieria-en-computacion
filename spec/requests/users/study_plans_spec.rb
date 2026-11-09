# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::StudyPlans" do
  describe "GET /users/study_plan/edit" do
    context "when nobody is signed in" do
      it "ask to log in" do
        get edit_users_study_plan_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when a user is signed in" do
      let!(:older) { create(:study_plan, year: 2011) }
      let(:user) { create(:user) }

      before do
        create(:study_plan, year: 2018)
        sign_in user
      end

      it "responds successfully" do
        get edit_users_study_plan_path
        expect(response).to have_http_status(:ok)
      end

      it "uses a titled page in Spanish" do
        get edit_users_study_plan_path
        assert_select "h1", text: I18n.t("users.study_plans.edit.title")
      end

      it "submits the form with PATCH" do
        get edit_users_study_plan_path
        assert_select "form[action='#{users_study_plan_path}'][method='post']" do
          assert_select "input[type='hidden'][name='_method'][value='patch']"
        end
      end

      it "offers one radio per plan, each with a label" do
        get edit_users_study_plan_path
        assert_select "input[type='radio'][name='user[study_plan_id]']", count: 2
        assert_select "label", text: /#{I18n.t("study_plans.card.title", year: 2018)}/
        assert_select "label", text: /#{I18n.t("study_plans.card.title", year: 2011)}/
      end

      it "lists the newest plan first" do
        get edit_users_study_plan_path
        expect(response.body).to match(/Plan 2018.*Plan 2011/m)
      end

      it "preselects nothing when the user has no plan" do
        get edit_users_study_plan_path
        assert_select "input[type='radio'][checked]", count: 0
      end

      it "preselects the plan the user follows" do
        user.update!(study_plan: older)
        get edit_users_study_plan_path
        assert_select "input[type='radio'][value='#{older.id}'][checked]", count: 1
      end
    end
  end
end
