# frozen_string_literal: true

require "rails_helper"

RSpec.describe Curriculum::Availability do
  def availability(statuses: {}, requirements: { 2 => [1] })
    described_class.new(subject_ids: [1, 2, 3], statuses: statuses, requirements: requirements)
  end

  describe "#status" do
    it "is available when the subject has no prerequisites" do
      expect(availability.status(1)).to eq("available")
    end

    it "is blocked when a prerequisite was never marked" do
      expect(availability.status(2)).to eq("blocked")
    end

    %w[pending in_progress].each do |status|
      it "is still blocked when the prerequisite is #{status}" do
        expect(availability(statuses: { 1 => status }).status(2)).to eq("blocked")
      end
    end

    %w[regular approved promoted].each do |status|
      it "is available when the prerequisite is #{status}" do
        expect(availability(statuses: { 1 => status }).status(2)).to eq("available")
      end
    end

    it "needs every prerequisite, not just one" do
      subject_with_two = availability(statuses: { 1 => "approved" }, requirements: { 2 => [1, 3] })
      expect(subject_with_two.status(2)).to eq("blocked")
    end

    it "is available when all the prerequisites are met" do
      subject_with_two = availability(statuses: { 1 => "approved", 3 => "regular" }, requirements: { 2 => [1, 3] })
      expect(subject_with_two.status(2)).to eq("available")
    end

    it "keeps the own status of a subject the student already marked, even if it is blocked" do
      expect(availability(statuses: { 2 => "in_progress" }).status(2)).to eq("in_progress")
    end

    it "treats a subject explicitly marked as pending like an unmarked one" do
      expect(availability(statuses: { 2 => "pending" }).status(2)).to eq("blocked")
    end
  end

  describe "#blocked?" do
    it "is true while a prerequisite is missing" do
      expect(availability).to be_blocked(2)
    end

    it "is false when the prerequisites are met" do
      expect(availability(statuses: { 1 => "regular" })).not_to be_blocked(2)
    end
  end

  describe "#missing_ids" do
    it "lists the prerequisites that are not met" do
      two_missing = availability(statuses: { 1 => "regular" }, requirements: { 2 => [1, 3] })
      expect(two_missing.missing_ids(2)).to eq([3])
    end

    it "is empty for a subject without prerequisites" do
      expect(availability.missing_ids(1)).to eq([])
    end
  end

  describe "#statuses" do
    it "gives the status to show for every subject of the plan" do
      expect(availability(statuses: { 3 => "approved" }).statuses).to eq(1 => "available", 2 => "blocked",
                                                                         3 => "approved")
    end
  end

  describe ".for" do
    let(:plan) { create(:study_plan) }
    let(:user) { create(:user, study_plan: plan) }
    let!(:algebra) { create(:subject, study_plan: plan) }
    let!(:geometry) { create(:subject, study_plan: plan) }

    before { create(:prerequisite, subject: geometry, required_subject: algebra) }

    it "blocks a subject until the user passed its prerequisite" do
      expect(described_class.for(user, plan).status(geometry.id)).to eq("blocked")
    end

    it "reads the progress of that user" do
      create(:subject_progress, user: user, subject: algebra, status: :regular)
      expect(described_class.for(user, plan).status(geometry.id)).to eq("available")
    end

    it "ignores the progress of other users" do
      create(:subject_progress, subject: algebra, status: :approved)
      expect(described_class.for(user, plan).status(geometry.id)).to eq("blocked")
    end

    it "only covers the subjects of that plan" do
      create(:subject)
      expect(described_class.for(user, plan).statuses.keys).to contain_exactly(algebra.id, geometry.id)
    end

    it "gives the missing prerequisites as subjects" do
      expect(described_class.for(user, plan).missing_subjects(geometry.id)).to eq([algebra])
    end
  end
end
