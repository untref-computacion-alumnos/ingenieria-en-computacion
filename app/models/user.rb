# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  belongs_to :study_plan, optional: true
  validates :study_plan, presence: true, on: :plan_selection
  after_create :assign_default_role

  private

  def assign_default_role
    add_role(:student)
  end
end
