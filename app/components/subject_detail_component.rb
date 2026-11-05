# frozen_string_literal: true

class SubjectDetailComponent < ViewComponent::Base
  def initialize(subject:)
    super()
    @subject = subject
  end

  private

  attr_reader :subject

  def prerequisites
    subject.required_subjects.sort_by(&:name)
  end

  def facts
    {
      code: subject.code,
      hours: subject.hours,
      credits: subject.credits
    }.compact
  end
end
