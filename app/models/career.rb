# frozen_string_literal: true

class Career < ApplicationRecord
  has_many :study_plans, dependent: :destroy
  validates :name, presence: true
end
