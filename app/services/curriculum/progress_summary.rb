# frozen_string_literal: true

module Curriculum
  class ProgressSummary
    COMPLETED_STATUSES = %w[approved promoted].freeze

    def initialize(statuses:)
      @statuses = statuses
    end

    def total
      statuses.size
    end

    def completed
      statuses.values.count { |status| COMPLETED_STATUSES.include?(status) }
    end

    def percent
      return 0 if total.zero?

      completed * 100 / total
    end

    private

    attr_reader :statuses
  end
end
