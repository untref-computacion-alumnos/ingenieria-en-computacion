# frozen_string_literal: true

class SubjectProgress < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  enum :status, { pending: 0, in_progress: 1, regular: 2, approved: 3, promoted: 4 }, default: :pending, validate: true
  validate :prerequisites_met, if: -> { in_progress? && will_save_change_to_status? }
  validates :subject_id, uniqueness: { scope: :user_id }

  private

  def prerequisites_met
    return unless user && subject

    errors.add(:status, :blocked) if Curriculum::Availability.for(user, subject.study_plan).blocked?(subject_id)
  end
end
