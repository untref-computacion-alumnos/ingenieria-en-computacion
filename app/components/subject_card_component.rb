# frozen_string_literal: true

class SubjectCardComponent < ViewComponent::Base
  def initialize(name:)
    super()
    @name = name
  end

  private

  attr_reader :name
end
