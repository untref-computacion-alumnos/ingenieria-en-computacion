# frozen_string_literal: true

class SubjectCardComponent < ViewComponent::Base
  def initialize(subject:)
    super()
    @subject = subject
  end

  private

  attr_reader :subject
end
