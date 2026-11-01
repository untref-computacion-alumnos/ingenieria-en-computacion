# frozen_string_literal: true

FactoryBot.define do
  factory :career do
    sequence(:name) { |n| "Career #{n}" }
  end
end
