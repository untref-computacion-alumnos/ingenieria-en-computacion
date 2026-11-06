# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  after_create :assign_default_role

  private

  def assign_default_role
    add_role(:student)
  end
end
