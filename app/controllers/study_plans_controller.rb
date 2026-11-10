# frozen_string_literal: true

class StudyPlansController < ApplicationController
  def index
    @study_plans = StudyPlan.with_subjects_count.order(year: :desc)
    @active_plan = StudyPlan.current
  end

  def show
    @study_plan = StudyPlan.find(params.expect(:id))
    @statuses = current_user.progress_statuses if user_signed_in?
  end
end
