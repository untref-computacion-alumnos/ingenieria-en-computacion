# frozen_string_literal: true

module Seeds
  class PlanLoader
    class Error < StandardError; end

    SUBJECT_ATTRIBUTES = %w[name year term hours credits].freeze

    def self.code_of(attributes)
      attributes.fetch("code").to_s
    end

    def initialize(path)
      @data = YAML.safe_load_file(path)
    end

    def call
      ActiveRecord::Base.transaction do
        career = load_career
        plan = load_plan(career)
        subjects = load_subjects(plan)
        load_prerequisites(subjects)
      end
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
        subject = plan.subjects.find_or_initialize_by(code: self.class.code_of(attributes))
        subject.update!(attributes.slice(*SUBJECT_ATTRIBUTES))
        [subject.code, subject]
      end
    end

    def load_prerequisites(subjects)
      prerequisite_pairs.each do |code, required_code|
        required = subjects[required_code] || raise(Error, "Unknown prerequisite #{required_code} for #{code}")
        subjects.fetch(code).prerequisites.find_or_create_by!(required_subject: required)
      end
    end

    def prerequisite_pairs
      parsed_subjects.flat_map do |attributes|
        [self.class.code_of(attributes)].product(attributes.fetch("prerequisites", []).map(&:to_s))
      end
    end

    def parsed_subjects
      @data.fetch("subjects")
    end
  end
end
