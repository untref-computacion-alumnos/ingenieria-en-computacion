# frozen_string_literal: true

class SubjectStatusPickerComponent < ViewComponent::Base
  def initialize(subject:, status:)
    super()
    @subject = subject
    @status = status
  end

  private

  attr_reader :subject, :status

  def dom_id
    ActionView::RecordIdentifier.dom_id(subject, :status_picker)
  end

  def statuses
    SubjectProgress.statuses.keys
  end

  def pressed?(candidate)
    candidate == status
  end

  def button_class(candidate)
    pressed?(candidate) ? "btn btn-sm btn-primary" : "btn btn-sm btn-outline"
  end
end
