# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    study_plan
    sequence(:code) { |n| format("%02d", n) }
    sequence(:name) { |n| "Subject #{n}" }
    year { 1 }
    term { 1 }
  end
end
