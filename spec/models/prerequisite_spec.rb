# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prerequisite do
  let(:plan) { create(:study_plan) }
  let(:algebra) { create(:subject, study_plan: plan) }

  it { is_expected.to belong_to(:subject) }
  it { is_expected.to belong_to(:required_subject).class_name("Subject") }

  it "rejects a subject that requires itself" do
    prerequisite = build(:prerequisite, subject: algebra, required_subject: algebra)
    prerequisite.valid?
    expect(prerequisite.errors).to be_of_kind(:required_subject, :self_reference)
  end
end
