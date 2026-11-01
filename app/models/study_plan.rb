# frozen_string_literal: true

class StudyPlan < ApplicationRecord
  belongs_to :career
  validates :year, presence: true, uniqueness: { scope: :career_id }

  def self.current
    order(:year).last
  end
end
