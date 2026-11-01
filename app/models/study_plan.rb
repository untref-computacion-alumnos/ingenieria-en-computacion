# frozen_string_literal: true

class StudyPlan < ApplicationRecord
  belongs_to :career
  has_many :subjects, dependent: :destroy
  validates :year, presence: true, uniqueness: { scope: :career_id }

  def self.current
    order(:year).last
  end
end
