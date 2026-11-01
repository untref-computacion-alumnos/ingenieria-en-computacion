# frozen_string_literal: true

class Prerequisite < ApplicationRecord
  belongs_to :subject
  belongs_to :required_subject, class_name: "Subject"
  validate :not_self_referencing

  private

  def not_self_referencing
    errors.add(:required_subject, :self_reference) if subject_id.present? && subject_id == required_subject_id
  end
end
