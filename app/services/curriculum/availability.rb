# frozen_string_literal: true

module Curriculum
  class Availability
    MET_STATUSES = %w[regular approved promoted].freeze

    def self.for(user, study_plan)
      subject_ids = study_plan.subjects.ids
      new(subject_ids: subject_ids, statuses: user.progress_statuses, requirements: requirements_of(subject_ids))
    end

    def self.requirements_of(subject_ids)
      pairs = Prerequisite.where(subject_id: subject_ids).pluck(:subject_id, :required_subject_id)
      pairs.group_by(&:first).transform_values { |group| group.map(&:last) }
    end

    private_class_method :requirements_of

    def initialize(subject_ids:, statuses:, requirements:)
      @subject_ids = subject_ids
      @progress = statuses
      @requirements = requirements
    end

    def status(subject_id)
      own = own_status(subject_id)
      return own unless own == "pending"

      blocked?(subject_id) ? "blocked" : "available"
    end

    def statuses
      subject_ids.index_with { |subject_id| status(subject_id) }
    end

    def blocked?(subject_id)
      missing_ids(subject_id).any?
    end

    def missing_ids(subject_id)
      requirements.fetch(subject_id, []).reject { |required_id| MET_STATUSES.include?(own_status(required_id)) }
    end

    def missing_subjects(subject_id)
      Subject.where(id: missing_ids(subject_id)).order(:name).to_a
    end

    private

    attr_reader :subject_ids, :progress, :requirements

    def own_status(subject_id)
      progress.fetch(subject_id, "pending")
    end
  end
end
