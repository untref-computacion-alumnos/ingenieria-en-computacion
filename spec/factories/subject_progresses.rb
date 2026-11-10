# frozen_string_literal: true

FactoryBot.define do
  factory :subject_progress do
    user
    subject
    status { :pending }
  end
end
