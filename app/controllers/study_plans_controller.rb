# frozen_string_literal: true

class StudyPlansController < ApplicationController
  def index
    @study_plans = StudyPlan.with_subjects_count.order(year: :desc)
  end

  def show
    study_plan = StudyPlan.find(params.expect(:id))
    @study_plan = study_plan
    assign_progress(study_plan) if user_signed_in?
  end

  private

  def assign_progress(study_plan)
    statuses = Curriculum::Availability.for(current_user, study_plan).statuses
    @statuses = statuses
    @progress = Curriculum::ProgressSummary.new(statuses: statuses) if current_user.study_plan_id == study_plan.id
  end
end
