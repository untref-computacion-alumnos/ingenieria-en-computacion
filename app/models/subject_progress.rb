# frozen_string_literal: true

class SubjectProgress < ApplicationRecord
  COMPLETED_STATUSES = %w[approved promoted].freeze

  belongs_to :user
  belongs_to :subject
  enum :status, { pending: 0, in_progress: 1, regular: 2, approved: 3, promoted: 4 }, default: :pending, validate: true
  before_validation :clear_record_of_uncompleted
  validate :prerequisites_met, if: -> { in_progress? && will_save_change_to_status? }
  validate :approved_on_not_in_the_future
  validates :subject_id, uniqueness: { scope: :user_id }
  validates :grade, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10, message: :invalid_grade },
                    allow_nil: true

  private

  def approved_on_not_in_the_future
    errors.add(:approved_on, :future) if approved_on && approved_on > Date.current
  end

  def clear_record_of_uncompleted
    self.final_exam_taken = false unless promoted?
    return if COMPLETED_STATUSES.include?(status)

    self.grade = nil
    self.approved_on = nil
  end

  def prerequisites_met
    return unless user && subject

    errors.add(:status, :blocked) if Curriculum::Availability.for(user, subject.study_plan).blocked?(subject_id)
  end
end
