# frozen_string_literal: true

FactoryBot.define do
  factory :study_plan do
    career
    sequence(:year) { |name| 2000 + name }
  end
end
