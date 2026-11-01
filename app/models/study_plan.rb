# frozen_string_literal: true

class StudyPlan < ApplicationRecord
  belongs_to :career
  validates :year, presence: true
end
