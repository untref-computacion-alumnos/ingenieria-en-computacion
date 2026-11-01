# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :study_plan
  validates :name, :code, presence: true
  validates :code, uniqueness: { scope: :study_plan_id }
  validates :year, inclusion: { in: 1..5 }
end
