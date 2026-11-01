# frozen_string_literal: true

FactoryBot.define do
  factory :career do
    sequence(:name) { |name| "Career #{name}" }
  end
end
