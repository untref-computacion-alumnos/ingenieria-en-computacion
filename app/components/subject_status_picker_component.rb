# frozen_string_literal: true

class SubjectStatusPickerComponent < ViewComponent::Base
  def initialize(subject:, status:, missing: [], rejected: false)
    super()
    @subject = subject
    @status = status
    @missing = missing
    @rejected = rejected
  end

  private

  attr_reader :subject, :status, :missing, :rejected

  def dom_id
    ActionView::RecordIdentifier.dom_id(subject, :status_picker)
  end

  def button_class(candidate)
    pressed?(candidate) ? "btn btn-sm btn-primary" : "btn btn-sm btn-outline"
  end

  def pressed?(candidate)
    candidate == status
  end

  def show_missing?
    missing.any? && (status == "pending" || rejected)
  end
end
