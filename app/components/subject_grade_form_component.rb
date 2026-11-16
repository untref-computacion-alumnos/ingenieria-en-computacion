# frozen_string_literal: true

class SubjectGradeFormComponent < ViewComponent::Base
  def initialize(subject:, progress:, saved:)
    super()
    @subject = subject
    @progress = progress
    @saved = saved
  end

  private

  attr_reader :subject, :progress, :saved

  def dom_id
    ActionView::RecordIdentifier.dom_id(subject, :grade_form)
  end

  def grade_value
    helpers.number_with_precision(progress.grade, precision: 1, strip_insignificant_zeros: true, locale: :en)
  end

  def hint_id(field)
    "#{dom_id}_#{field}_hint"
  end

  def promoted?
    progress.promoted?
  end

  def show_form?
    progress && SubjectProgress::COMPLETED_STATUSES.include?(progress.status)
  end
end
