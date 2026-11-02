# frozen_string_literal: true

require "rails_helper"

RSpec.describe Seeds::PlanLoader do
  def loader_for(fixture)
    described_class.new(Rails.root.join("spec/fixtures/plans/#{fixture}.yml"))
  end

  it "creates the career and its plan" do
    loader_for("mini").call
    expect(Career.sole.study_plans.pluck(:year)).to eq([2018])
  end

  it "creates the subjects with their attributes" do
    loader_for("mini").call
    expect(Subject.find_by(code: "02")).to have_attributes(name: "Programación I", year: 1, term: 2, hours: 96)
  end

  it "creates the prerequisites" do
    loader_for("mini").call
    expect(Subject.find_by(code: "03").required_subjects.pluck(:code)).to eq(["02"])
  end

  it "can run twice without duplicating anything" do
    2.times { loader_for("mini").call }
    expect([Career.count, StudyPlan.count, Subject.count, Prerequisite.count]).to eq([1, 1, 3, 2])
  end

  it "fails when a prerequisite code does not exist" do
    expect { loader_for("unknown_prerequisite").call }.to raise_error(described_class::Error, /Unknown prerequisite 99/)
  end
end
