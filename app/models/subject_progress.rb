# frozen_string_literal: true

class SubjectProgress < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  enum :status, { pending: 0, in_progress: 1, regular: 2, approved: 3, promoted: 4 }, default: :pending, validate: true
  validates :subject_id, uniqueness: { scope: :user_id }
end
