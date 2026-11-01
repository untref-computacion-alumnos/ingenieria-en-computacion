# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prerequisite do
  let(:plan) { create(:study_plan) }
  let(:algebra) { create(:subject, study_plan: plan) }
  let(:programming) { create(:subject, study_plan: plan) }

  it { is_expected.to belong_to(:subject) }
  it { is_expected.to belong_to(:required_subject).class_name("Subject") }

  it "rejects a subject that requires itself" do
    prerequisite = build(:prerequisite, subject: algebra, required_subject: algebra)
    prerequisite.valid?
    expect(prerequisite.errors).to be_of_kind(:required_subject, :self_reference)
  end

  it "rejects the same requirement twice" do
    create(:prerequisite, subject: programming, required_subject: algebra)
    expect(build(:prerequisite, subject: programming, required_subject: algebra)).not_to be_valid
  end

  it "rejects a requirement from another plan" do
    other = create(:subject)
    prerequisite = build(:prerequisite, subject: algebra, required_subject: other)
    prerequisite.valid?
    expect(prerequisite.errors).to be_of_kind(:required_subject, :different_study_plan)
  end

  it "rejects a direct cycle" do
    create(:prerequisite, subject: programming, required_subject: algebra)
    cycle = build(:prerequisite, subject: algebra, required_subject: programming)
    cycle.valid?
    expect(cycle.errors).to be_of_kind(:required_subject, :circular)
  end
end
