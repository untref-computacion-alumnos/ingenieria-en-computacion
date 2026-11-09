# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudyPlan do
  it { is_expected.to belong_to(:career) }
  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to have_many(:subjects).dependent(:destroy) }
  it { is_expected.to have_many(:users).dependent(:nullify) }

  it "rejects a second plan with the same year in the same career" do
    existing = create(:study_plan, year: 2018)
    duplicate = build(:study_plan, career: existing.career, year: 2018)
    expect(duplicate).not_to be_valid
  end

  describe ".current" do
    it "returns the plan with the latest year" do
      create(:study_plan, year: 2011)
      latest = create(:study_plan, year: 2018)
      expect(described_class.current).to eq(latest)
    end
  end

  describe ".with_subjects_count" do
    it "adds the number of subjects of each plan, including plans without subjects" do
      full = create(:study_plan, year: 2022)
      create_list(:subject, 2, study_plan: full)
      empty = create(:study_plan, year: 2013)
      counts = described_class.with_subjects_count.to_h { |plan| [plan.id, plan.subjects_count] }
      expect(counts).to eq(full.id => 2, empty.id => 0)
    end
  end
end
