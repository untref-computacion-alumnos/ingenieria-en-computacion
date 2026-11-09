# frozen_string_literal: true

class StudyPlan < ApplicationRecord
  belongs_to :career
  has_many :subjects, dependent: :destroy
  has_many :users, dependent: :nullify
  validates :year, presence: true, uniqueness: { scope: :career_id }
  scope :with_subjects_count, lambda {
    left_joins(:subjects).group(:id).select("study_plans.*", "COUNT(subjects.id) AS subjects_count")
  }

  def self.current
    order(:year).last
  end
end
