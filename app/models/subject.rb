# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :study_plan
  has_many :prerequisites, dependent: :destroy
  has_many :subject_progresses, dependent: :destroy
  has_many :required_subjects, through: :prerequisites
  has_many :inverse_prerequisites, class_name: "Prerequisite", foreign_key: :required_subject_id,
                                   inverse_of: :required_subject, dependent: :destroy
  has_many :dependent_subjects, through: :inverse_prerequisites, source: :subject
  validates :name, :code, presence: true
  validates :code, uniqueness: { scope: :study_plan_id }
  validates :year, inclusion: { in: 1..5 }
  validates :term, inclusion: { in: 1..2 }
  validates :hours, :credits, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def transitively_requires?(other)
    all_required_subjects.include?(other)
  end

  protected

  def all_required_subjects(visited = Set.new)
    required_subjects.each do |required|
      required.all_required_subjects(visited) if visited.add?(required)
    end
    visited
  end
end
