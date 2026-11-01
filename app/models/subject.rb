# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :study_plan
  validates :name, presence: true
end
