# frozen_string_literal: true

class SubjectStatusBadgeComponent < ViewComponent::Base
  COLOR_CLASSES = {
    "pending" => "border-0 bg-status-pending text-status-content",
    "available" => "border-0 bg-status-pending text-status-content",
    "blocked" => "border border-base-300 bg-base-200 text-base-content/70",
    "in_progress" => "border-0 bg-status-in-progress text-status-content",
    "regular" => "border-0 bg-status-regular text-status-content",
    "approved" => "border-0 bg-status-approved text-status-content",
    "promoted" => "border-0 bg-status-promoted text-status-content"
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
