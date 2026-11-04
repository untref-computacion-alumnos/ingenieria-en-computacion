# frozen_string_literal: true

class SubjectsController < ApplicationController
  def show
    # @subject = Subject.includes(:study_plan, :required_subjects).find(params.expect(:id))
    @subject = Subject.find(params.expect(:id))
  end
end
