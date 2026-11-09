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

  describe "PATCH /users/study_plan" do
    let!(:older) { create(:study_plan, year: 2011) }
    let!(:newer) { create(:study_plan, year: 2018) }
    let(:user) { create(:user) }

    def choose_plan(plan_id)
      patch users_study_plan_path, params: { user: { study_plan_id: plan_id } }
    end

    context "when nobody is signed in" do
      it "asks to log in and changes nothing" do
        patch users_study_plan_path, params: { user: { study_plan_id: newer.id } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "with a plan that exists" do
      before { sign_in user }

      it "saves the plan" do
        expect { choose_plan(newer.id) }.to change { user.reload.study_plan }.from(nil).to(newer)
      end

      it "goes to the grid of that plan" do
        choose_plan(newer.id)
        expect(response).to redirect_to(study_plan_path(newer))
      end

      it "redirects with 303" do
        choose_plan(newer.id)
        expect(response).to have_http_status(:see_other)
      end

      it "says which plan was chosen" do
        choose_plan(newer.id)
        follow_redirect!
        assert_select "[role='status']", text: I18n.t("users.study_plans.update.success", year: 2018)
      end

      it "lets the user change to another plan" do
        user.update!(study_plan: older)
        expect { choose_plan(newer.id) }.to change { user.reload.study_plan }.from(older).to(newer)
      end
    end

    context "with nothing chosen" do
      before { sign_in user }

      it "renders the form again with an error status" do
        patch users_study_plan_path
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "shows the error summary" do
        patch users_study_plan_path
        assert_select "#error_explanation li"
      end

      it "keeps the plan the user already had" do
        user.update!(study_plan: older)
        expect { patch users_study_plan_path }.not_to(change { user.reload.study_plan })
      end
    end

    context "with a plan that does not exist" do
      before { sign_in user }

      it "renders the form again with an error status, not a server error" do
        choose_plan(0)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not change the plan" do
        user.update!(study_plan: older)
        expect { choose_plan(0) }.not_to(change { user.reload.study_plan })
      end
    end
  end
end
