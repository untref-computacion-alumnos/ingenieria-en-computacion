# frozen_string_literal: true

class SubjectProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_study_plan
  before_action :set_subject

  def update
    @progress = SubjectProgress.find_or_initialize_by(user: current_user, subject: @subject)
    authorize @progress
    if @progress.update(status: status_param)
      redirect_to subject_path(@subject), status: :see_other
    else
      head :unprocessable_content
    end
  end

  private

  def set_subject
    @subject = Subject.find(params.expect(:subject_id))
  end

  def status_param
    params.permit(:status)[:status]
  end
end
