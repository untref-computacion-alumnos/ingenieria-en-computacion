# frozen_string_literal: true

module Users
  class StudyPlansController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_user

    def edit
      @study_plans = StudyPlan.order(year: :desc)
    end

    def update
      study_plan = StudyPlan.find_by(id: params.dig(:user, :study_plan_id))
      current_user.study_plan = study_plan
      if current_user.save(context: :plan_selection)
        redirect_to study_plan_path(study_plan), notice: t(".success", year: study_plan.year), status: :see_other
      else
        @study_plans = StudyPlan.order(year: :desc)
        render :edit, status: :unprocessable_content
      end
    end

    private

    def authorize_user
      authorize current_user
    end
  end
end
