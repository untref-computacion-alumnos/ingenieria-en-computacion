# frozen_string_literal: true

FactoryBot.define do
  factory :study_plan do
    career
    sequence(:year) { |n| 2000 + n }
  end
end
