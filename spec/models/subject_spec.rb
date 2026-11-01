# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subject do
  it { is_expected.to belong_to(:study_plan) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code) }

  it "rejects a repeated code inside the same plan" do
    existing = create(:subject, code: "01")
    duplicate = build(:subject, study_plan: existing.study_plan, code: "01")
    expect(duplicate).not_to be_valid
  end
end
