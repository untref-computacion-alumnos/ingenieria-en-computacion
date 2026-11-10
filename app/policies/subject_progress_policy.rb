# frozen_string_literal: true

class SubjectProgressPolicy < ApplicationPolicy
  def update?
    user.present? && record.user_id == user.id
  end
end
