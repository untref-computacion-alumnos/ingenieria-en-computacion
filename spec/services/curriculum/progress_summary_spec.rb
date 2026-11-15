# frozen_string_literal: true

require "rails_helper"

RSpec.describe Curriculum::ProgressSummary do
  def summary(statuses)
    described_class.new(statuses: statuses)
  end

  describe "#total" do
    it "counts every subject of the plan" do
      expect(summary(1 => "available", 2 => "blocked", 3 => "approved").total).to eq(3)
    end

    it "is zero for a plan without subjects" do
      expect(summary({}).total).to eq(0)
    end
  end

  describe "#completed" do
    it "counts approved subjects" do
      expect(summary(1 => "approved", 2 => "available").completed).to eq(1)
    end

    it "counts promoted subjects" do
      expect(summary(1 => "promoted", 2 => "available").completed).to eq(1)
    end

    %w[pending available blocked in_progress regular].each do |status|
      it "does not count a #{status} subject" do
        expect(summary(1 => status).completed).to eq(0)
      end
    end
  end

  describe "#percent" do
    it "is zero when nothing is completed" do
      expect(summary(1 => "available", 2 => "blocked").percent).to eq(0)
    end

    it "is 100 when everything is completed" do
      expect(summary(1 => "approved", 2 => "promoted").percent).to eq(100)
    end

    it "rounds down" do
      expect(summary(1 => "approved", 2 => "available", 3 => "blocked").percent).to eq(33)
    end

    it "rounds down also when it is close to the next integer" do
      expect(summary(1 => "approved", 2 => "approved", 3 => "blocked").percent).to eq(66)
    end

    it "is zero for a plan without subjects instead of failing" do
      expect(summary({}).percent).to eq(0)
    end
  end
end
