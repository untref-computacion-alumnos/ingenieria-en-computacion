# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudyPlan do
  it { is_expected.to belong_to(:career) }
  it { is_expected.to validate_presence_of(:year) }

  it "rejects a second plan with the same year in the same career" do
    existing = create(:study_plan, year: 2018)
    duplicate = build(:study_plan, career: existing.career, year: 2018)
    expect(duplicate).not_to be_valid
  end
end
