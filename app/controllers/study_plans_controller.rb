# frozen_string_literal: true

class StudyPlansController < ApplicationController
  def index
    @study_plans = StudyPlan.order(year: :desc)
  end
end
