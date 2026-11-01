# frozen_string_literal: true

module Seeds
  class PlanLoader
    def initialize(path)
      @data = YAML.safe_load_file(path)
    end

    def call
      career = Career.create!(name: @data.fetch("career"))
      career.study_plans.create!(year: @data.fetch("year"))
    end
  end
end
