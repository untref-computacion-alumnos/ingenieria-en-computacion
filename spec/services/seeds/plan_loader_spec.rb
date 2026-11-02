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
end
