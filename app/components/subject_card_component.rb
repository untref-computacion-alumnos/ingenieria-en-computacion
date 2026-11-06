# frozen_string_literal: true

class SubjectCardComponent < ViewComponent::Base
  def initialize(subject:)
    super()
    @subject = subject
  end

  private

  attr_reader :subject

  def required_ids
    subject.prerequisites.map(&:required_subject_id)
  end
end
