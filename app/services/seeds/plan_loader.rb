# frozen_string_literal: true

module Seeds
  class PlanLoader
    def initialize(path)
      @data = YAML.safe_load_file(path)
    end

    def call
      career = create_career
      plan = create_plan(career)
      subjects = create_subjects(plan)

      create_prerequisites(subjects)
    end

    private

    def create_career
      Career.create!(name: @data.fetch("career"))
    end

    def create_plan(career)
      career.study_plans.create!(year: @data.fetch("year"))
    end

    def create_subjects(plan)
      parsed_subjects.to_h do |attributes|
        subject = plan.subjects.create!(subject_attributes(attributes))
        [subject.code, subject]
      end
    end

    def create_prerequisites(subjects)
      parsed_subjects.each do |attributes|
        subject = subjects.fetch(attributes.fetch("code"))
        attributes.fetch("prerequisites", []).each do |req_code|
          subject.prerequisites.create!(required_subject: subjects.fetch(req_code))
        end
      end
    end

    def subject_attributes(attributes)
      attributes.slice("code", "name", "year", "term", "hours", "credits")
    end

    def parsed_subjects
      @data.fetch("subjects")
    end
  end
end
