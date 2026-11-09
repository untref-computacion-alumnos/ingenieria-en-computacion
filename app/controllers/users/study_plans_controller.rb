# frozen_string_literal: true

module Users
  class StudyPlansController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user

    def edit
      @study_plans = StudyPlan.order(year: :desc)
    end

    private

    def set_user
      @user = current_user
      authorize @user
    end
  end
end
