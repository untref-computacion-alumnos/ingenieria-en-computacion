# frozen_string_literal: true

class SubjectCardComponent < ViewComponent::Base
  def initialize(subject:, status: nil)
    super()
    @subject = subject
    @status = status
  end

  private

  attr_reader :subject, :status

  def required_ids
    subject.prerequisites.map(&:required_subject_id)
  end
end
