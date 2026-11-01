# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subject do
  it { is_expected.to belong_to(:study_plan) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_inclusion_of(:year).in_array((1..5).to_a) }
  it { is_expected.to validate_inclusion_of(:term).in_array([1, 2]) }
  it { is_expected.to validate_numericality_of(:hours).only_integer.is_greater_than(0).allow_nil }
  it { is_expected.to validate_numericality_of(:credits).only_integer.is_greater_than(0).allow_nil }

  it "rejects a repeated code inside the same plan" do
    existing = create(:subject, code: "01")
    duplicate = build(:subject, study_plan: existing.study_plan, code: "01")
    expect(duplicate).not_to be_valid
  end

  describe "#transitively_requires?" do
    let(:plan) { create(:study_plan) }
    let(:first) { create(:subject, study_plan: plan) }
    let(:second) { create(:subject, study_plan: plan) }
    let(:third) { create(:subject, study_plan: plan) }

    before do
      create(:prerequisite, subject: second, required_subject: first)
      create(:prerequisite, subject: third, required_subject: second)
    end

    it { expect(third).to be_transitively_requires(first) }
    it { expect(first).not_to be_transitively_requires(third) }
  end
end
