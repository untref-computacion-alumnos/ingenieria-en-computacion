# frozen_string_literal: true

class SubjectProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_study_plan

  def update
    subject = Subject.find(params.expect(:subject_id))
    progress = SubjectProgress.find_or_initialize_by(user: current_user, subject: subject)
    authorize progress
    progress.update(status: status_param) ? respond_updated(subject) : respond_rejected(subject, progress)
  end

  private

  def respond_blocked(subject)
    respond_to do |format|
      format.turbo_stream { render :blocked, status: :unprocessable_content, locals: stream_locals(subject) }
      format.html do
        redirect_to subject_path(subject), alert: t("subject_progresses.update.blocked"), status: :see_other
      end
    end
  end

  def respond_rejected(subject, progress)
    return head(:unprocessable_content) unless progress.errors.of_kind?(:status, :blocked)

    respond_blocked(subject)
  end

  def respond_updated(subject)
    respond_to do |format|
      format.turbo_stream { render locals: stream_locals(subject) }
      format.html { redirect_to subject_path(subject), status: :see_other }
    end
  end

  def status_param
    params.permit(:status)[:status]
  end

  def stream_locals(subject)
    availability = Curriculum::Availability.for(current_user, subject.study_plan)
    {
      subject: subject,
      status: current_user.status_for(subject),
      missing: availability.missing_subjects(subject.id),
      badges: ([subject] + subject.dependent_subjects).index_with { |item| availability.status(item.id) }
    }
  end
end
