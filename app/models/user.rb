# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  belongs_to :study_plan, optional: true
  has_many :subject_progresses, dependent: :destroy
  validates :study_plan, presence: true, on: :plan_selection
  after_create :assign_default_role

  def status_for(subject)
    progress_statuses[subject.id]
  end

  def progress_statuses
    Hash.new("pending").merge(subject_progresses.pluck(:subject_id, :status).to_h)
  end

  private

  def assign_default_role
    add_role(:student)
  end
end
