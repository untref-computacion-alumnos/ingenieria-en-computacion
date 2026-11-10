# frozen_string_literal: true

class PlanGridComponent < ViewComponent::Base
  def initialize(subjects_by_term:, statuses: {})
    super()
    @subjects_by_term = subjects_by_term
    @statuses = statuses
  end

  private

  attr_reader :subjects_by_term, :statuses
end
