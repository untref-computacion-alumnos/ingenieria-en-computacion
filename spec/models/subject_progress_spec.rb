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
end
