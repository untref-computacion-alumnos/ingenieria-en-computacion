# frozen_string_literal: true

class ProgressBarComponent < ViewComponent::Base
  def initialize(progress:)
    super()
    @progress = progress
  end

  private

  attr_reader :progress
end
