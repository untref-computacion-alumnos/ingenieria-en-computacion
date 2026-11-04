# frozen_string_literal: true

class PlanGridComponent < ViewComponent::Base
  def initialize(subjects_by_term:)
    super()
    @subjects_by_term = subjects_by_term
  end

  private

  attr_reader :subjects_by_term
end
