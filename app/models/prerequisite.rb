# frozen_string_literal: true

class Prerequisite < ApplicationRecord
  belongs_to :subject
  belongs_to :required_subject, class_name: "Subject"
  validate :not_self_referencing
  validate :not_circular
  validate :same_study_plan
  validates :required_subject_id, uniqueness: { scope: :subject_id }

  private

  def not_self_referencing
    errors.add(:required_subject, :self_reference) if subject_id.present? && subject_id == required_subject_id
  end

  def not_circular
    return unless subject && required_subject

    reverse = Prerequisite.exists?(subject: required_subject, required_subject: subject)
    errors.add(:required_subject, :circular) if reverse
  end

  def same_study_plan
    return unless subject && required_subject
    return if subject.study_plan_id == required_subject.study_plan_id

    errors.add(:required_subject, :different_study_plan)
  end
end
