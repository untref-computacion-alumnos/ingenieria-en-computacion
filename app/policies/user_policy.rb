# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    user.present? && user == record
  end
end
