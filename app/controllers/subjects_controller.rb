# frozen_string_literal: true

class SubjectsController < ApplicationController
  def show
    # @subject = Subject.includes(:study_plan, :required_subjects).find(params.expect(:id))
    @subject = Subject.find(params.expect(:id))
    @status = current_user.status_for(@subject) if user_signed_in?
  end
end
