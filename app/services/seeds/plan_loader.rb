# frozen_string_literal: true

module Seeds
  class PlanLoader
    def initialize(path)
      @data = YAML.safe_load_file(path)
    end

    def call
      career = Career.create!(name: @data.fetch("career"))
      plan = career.study_plans.create!(year: @data.fetch("year"))
      @data.fetch("subjects").each do |attributes|
        plan.subjects.create!(attributes.slice("code", "name", "year", "term", "hours", "credits"))
      end
    end
  end
end
