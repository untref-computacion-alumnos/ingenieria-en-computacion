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

  describe "#subjects_by_term" do
    let(:plan) { create(:study_plan) }

    before do
      create(:subject, study_plan: plan, year: 2, term: 1, name: "Redes")
      create(:subject, study_plan: plan, year: 1, term: 2, name: "Física")
      create(:subject, study_plan: plan, year: 1, term: 1, name: "Álgebra")
      create(:subject, study_plan: plan, year: 1, term: 1, name: "Análisis")
    end

    it "groups the subjects by year and term" do
      expect(plan.subjects_by_term.keys).to contain_exactly([1, 1], [1, 2], [2, 1])
    end

    it "sorts the subjects of a term by name" do
      expect(plan.subjects_by_term[[1, 1]].map(&:name)).to eq(%w[Álgebra Análisis])
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
