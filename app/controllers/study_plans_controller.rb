# frozen_string_literal: true

class StudyPlansController < ApplicationController
  def index
    @study_plans = StudyPlan.with_subjects_count.order(year: :desc)
    @active_plan = StudyPlan.current
  end
end
