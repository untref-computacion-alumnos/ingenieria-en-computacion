# frozen_string_literal: true

class StudyPlansController < ApplicationController
  def index
    @study_plans = StudyPlan.with_subjects_count.order(year: :desc)
    @active_plan = StudyPlan.current
  end

  def show
    study_plan = StudyPlan.find(params.expect(:id))
    subjects = study_plan.subjects.includes(:prerequisites).order(:year, :term, :name)
    @study_plan = study_plan
    @subjects_by_term = subjects.group_by { |subject| [subject.year, subject.term] }
  end
end
