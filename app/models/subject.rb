# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :study_plan
  has_many :prerequisites, dependent: :destroy
  has_many :required_subjects, through: :prerequisites
  validates :name, :code, presence: true
  validates :code, uniqueness: { scope: :study_plan_id }
  validates :year, inclusion: { in: 1..5 }
  validates :term, inclusion: { in: 1..2 }
  validates :hours, :credits, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def transitively_requires?(other)
    visited = Set.new
    pending = required_subjects.to_a
    until pending.empty?
      current = pending.pop
      return true if current == other

      pending.concat(current.required_subjects) if visited.add?(current)
    end
    false
  end
end
