# frozen_string_literal: true

class SubjectsController < ApplicationController
  def show
    subject = Subject.find(params.expect(:id))
    @subject = subject
    return unless user_signed_in?

    @status = current_user.status_for(subject)
    @missing = Curriculum::Availability.for(current_user, subject.study_plan).missing_subjects(subject.id)
  end
end
