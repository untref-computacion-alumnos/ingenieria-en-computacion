# frozen_string_literal: true

module Users
  class StudyPlansController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user

    def edit
      @study_plans = StudyPlan.order(year: :desc)
    end

    def update
      @user.study_plan = StudyPlan.find_by(id: params.dig(:user, :study_plan_id))
      if @user.save(context: :plan_selection)
        redirect_to study_plan_path(@user.study_plan), notice: t(".success", year: @user.study_plan.year),
                                                       status: :see_other
      else
        @study_plans = StudyPlan.order(year: :desc)
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_user
      @user = current_user
      authorize @user
    end
  end
end
