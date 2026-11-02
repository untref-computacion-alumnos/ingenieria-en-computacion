# frozen_string_literal: true

FactoryBot.define do
  factory :prerequisite do
    transient { study_plan { association :study_plan } }
    subject { association :subject, study_plan: study_plan }
    required_subject { association :subject, study_plan: study_plan }
  end
end
