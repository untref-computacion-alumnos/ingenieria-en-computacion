# frozen_string_literal: true

class StudyPlanCardComponent < ViewComponent::Base
  def initialize(year:, subjects_count:, active:)
    super()
    @year = year
    @subjects_count = subjects_count
    @active = active
  end

  private

  attr_reader :year, :subjects_count, :active
end
