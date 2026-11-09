# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "student#{n}@example.com" }
    password { "a-long-password" }

    trait :with_study_plan do
      study_plan
    end
  end
end
