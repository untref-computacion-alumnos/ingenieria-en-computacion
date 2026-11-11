# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectProgress do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:subject) }

  it "is pending by default" do
    expect(described_class.new.status).to eq("pending")
  end

  it "knows the five statuses of the MVP" do
    expect(described_class.statuses.keys).to eq(%w[pending in_progress regular approved promoted])
  end

  it "rejects a status that does not exist" do
    progress = build(:subject_progress)
    progress.status = "free"
    expect(progress).not_to be_valid
  end

  it "rejects a missing status" do
    progress = build(:subject_progress)
    progress.status = nil
    expect(progress).not_to be_valid
  end

  it "rejects a second row for the same user and subject" do
    existing = create(:subject_progress)
    duplicate = build(:subject_progress, user: existing.user, subject: existing.subject)
    expect(duplicate).not_to be_valid
  end

  it "allows the same subject for different users" do
    existing = create(:subject_progress)
    other = build(:subject_progress, subject: existing.subject)
    expect(other).to be_valid
  end

  describe "prerequisites" do
    let(:plan) { create(:study_plan) }
    let(:user) { create(:user, study_plan: plan) }
    let(:algebra) { create(:subject, study_plan: plan) }
    let(:geometry) { create(:subject, study_plan: plan) }

    before { create(:prerequisite, subject: geometry, required_subject: algebra) }

    it "does not let a user start a subject whose prerequisite is missing" do
      progress = build(:subject_progress, user: user, subject: geometry, status: :in_progress)
      expect(progress).not_to be_valid
    end

    it "reports the problem on the status" do
      progress = build(:subject_progress, user: user, subject: geometry, status: :in_progress)
      progress.valid?
      expect(progress.errors).to be_of_kind(:status, :blocked)
    end

    it "lets the user start it once the prerequisite is regular" do
      create(:subject_progress, user: user, subject: algebra, status: :regular)
      progress = build(:subject_progress, user: user, subject: geometry, status: :in_progress)
      expect(progress).to be_valid
    end

    it "only blocks in progress, any other status is accepted" do
      progress = build(:subject_progress, user: user, subject: geometry, status: :regular)
      expect(progress).to be_valid
    end

    it "does not check again a subject that was already in progress" do
      create(:subject_progress, user: user, subject: algebra, status: :regular)
      progress = create(:subject_progress, user: user, subject: geometry, status: :in_progress)
      described_class.find_by!(user: user, subject: algebra).update!(status: :pending)
      expect(progress.reload).to be_valid
    end
  end
end
