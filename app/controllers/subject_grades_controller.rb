# frozen_string_literal: true

class SubjectGradesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_study_plan

  def update
    subject = Subject.find(params.expect(:subject_id))
    progress = current_user.subject_progresses.find_by!(subject: subject)
    authorize progress, :update?
    progress.update(grade_params) ? respond_saved(subject, progress) : respond_rejected(subject, progress)
  end

  private

  def grade_params
    params.expect(subject_progress: %i[grade approved_on final_exam_taken])
  end

  def respond_rejected(subject, progress)
    respond_to do |format|
      format.turbo_stream do
        render :update, status: :unprocessable_content, locals: { subject: subject, progress: progress, saved: false }
      end
      format.html do
        redirect_to subject_path(subject), alert: progress.errors.full_messages.to_sentence, status: :see_other
      end
    end
  end

  def respond_saved(subject, progress)
    respond_to do |format|
      format.turbo_stream { render locals: { subject: subject, progress: progress, saved: true } }
      format.html do
        redirect_to subject_path(subject), notice: t("subject_grades.form.saved"), status: :see_other
      end
    end
  end
end
