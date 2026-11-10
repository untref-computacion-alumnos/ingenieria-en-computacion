# frozen_string_literal: true

class SubjectProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_study_plan

  def update
    subject = Subject.find(params.expect(:subject_id))
    progress = SubjectProgress.find_or_initialize_by(user: current_user, subject: subject)
    authorize progress
    if progress.update(status: status_param)
      respond_updated(subject, progress.status)
    else
      head :unprocessable_content
    end
  end

  private

  def respond_updated(subject, status)
    respond_to do |format|
      format.turbo_stream { render locals: { subject: subject, status: status } }
      format.html { redirect_to subject_path(subject), status: :see_other }
    end
  end

  def status_param
    params.permit(:status)[:status]
  end
end
