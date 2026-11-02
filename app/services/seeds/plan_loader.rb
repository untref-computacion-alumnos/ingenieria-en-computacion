# frozen_string_literal: true

module Seeds
  class PlanLoader
    class Error < StandardError; end

    def initialize(path)
      @data = YAML.safe_load_file(path)
    end

    def call
      career = load_career
      plan = load_plan(career)
      subjects = load_subjects(plan)

      load_prerequisites(subjects)
    end

    private

    def load_career
      Career.find_or_create_by!(name: @data.fetch("career"))
    end

    def load_plan(career)
      career.study_plans.find_or_create_by!(year: @data.fetch("year"))
    end

    def load_subjects(plan)
      parsed_subjects.to_h do |attributes|
        subject = plan.subjects.find_or_initialize_by(code: attributes.fetch("code"))
        subject.update!(subject_attributes(attributes))
        [subject.code, subject]
      end
    end

    def load_prerequisites(subjects)
      parsed_subjects.each do |attributes|
        subject = subjects.fetch(attributes.fetch("code"))
        attributes.fetch("prerequisites", []).each do |req_code|
          required = subjects.fetch(req_code) do
            raise Error, "Unknown prerequisite #{req_code} for #{attributes.fetch("code")}"
          end
          subject.prerequisites.find_or_create_by!(required_subject: required)
        end
      end
    end

    def subject_attributes(attributes)
      attributes.slice("name", "year", "term", "hours", "credits")
    end

    def parsed_subjects
      @data.fetch("subjects")
    end
  end
end
