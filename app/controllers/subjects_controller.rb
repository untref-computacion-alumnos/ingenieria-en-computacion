# frozen_string_literal: true

class SubjectsController < ApplicationController
  def show
    subject = @subject = Subject.find(params.expect(:id))
    return unless user_signed_in?

    @status = current_user.status_for(subject)
    @missing = Curriculum::Availability.for(current_user, subject.study_plan).missing_subjects(subject.id)
    @progress = current_user.subject_progresses.find_by(subject: subject)
  end
end
