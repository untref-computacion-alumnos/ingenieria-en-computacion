# frozen_string_literal: true

class SubjectStatusBadgeComponent < ViewComponent::Base
  COLOR_CLASSES = {
    "pending" => "bg-status-pending",
    "in_progress" => "bg-status-in-progress",
    "regular" => "bg-status-regular",
    "approved" => "bg-status-approved",
    "promoted" => "bg-status-promoted"
  }.freeze

  def initialize(subject:, status:)
    super()
    @subject = subject
    @status = status
  end

  private

  attr_reader :subject, :status

  def dom_id
    ActionView::RecordIdentifier.dom_id(subject, :status)
  end

  def color_class
    COLOR_CLASSES.fetch(status)
  end
end
