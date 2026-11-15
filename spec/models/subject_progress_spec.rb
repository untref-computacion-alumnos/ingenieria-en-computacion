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

  describe "grade, approval date and final exam" do
    subject { build(:subject_progress, status: :approved) }

    it { is_expected.to allow_value(nil).for(:grade) }
    it { is_expected.to allow_value(1).for(:grade) }
    it { is_expected.to allow_value(8).for(:grade) }
    it { is_expected.to allow_value(7.5).for(:grade) }
    it { is_expected.to allow_value(10).for(:grade) }
    it { is_expected.not_to allow_value(0).for(:grade) }
    it { is_expected.not_to allow_value(0.9).for(:grade) }
    it { is_expected.not_to allow_value(11).for(:grade) }
    it { is_expected.not_to allow_value(-3).for(:grade) }
    it { is_expected.to allow_value(nil).for(:approved_on) }
    it { is_expected.to allow_value(Date.current).for(:approved_on) }
    it { is_expected.to allow_value(Date.new(2024, 12, 10)).for(:approved_on) }
    it { is_expected.not_to allow_value(Date.current.next_day).for(:approved_on) }

    it "starts without grade or date, and without a final exam" do
      progress = described_class.new
      expect([progress.grade, progress.approved_on, progress.final_exam_taken]).to eq([nil, nil, false])
    end

    it "does not require a grade or a date to be approved" do
      expect(build(:subject_progress, status: :approved)).to be_valid
    end

    it "reports a bad grade on the grade" do
      progress = build(:subject_progress, status: :approved, grade: 11)
      progress.valid?
      message = I18n.t("activerecord.errors.models.subject_progress.attributes.grade.invalid_grade")
      expect(progress.errors[:grade]).to eq([message])
    end

    it "reports a future date on the date" do
      progress = build(:subject_progress, status: :approved, approved_on: Date.current.next_day)
      progress.valid?
      expect(progress.errors).to be_of_kind(:approved_on, :future)
    end
  end

  describe "when the subject is not completed" do
    def saved_with(status, **attributes)
      progress = create(:subject_progress, status: :approved, **attributes)
      progress.update!(status: status)
      progress.reload
    end

    let(:record) { { grade: 8, approved_on: Date.new(2024, 12, 10), final_exam_taken: true } }

    it "keeps the grade and the date while it is approved" do
      progress = saved_with(:approved, **record)
      expect([progress.grade.to_i, progress.approved_on]).to eq([8, Date.new(2024, 12, 10)])
    end

    it "keeps the grade and the date while it is promoted" do
      progress = saved_with(:promoted, **record)
      expect([progress.grade.to_i, progress.approved_on]).to eq([8, Date.new(2024, 12, 10)])
    end

    %i[pending in_progress regular].each do |status|
      it "forgets the grade and the date when it goes back to #{status}" do
        progress = saved_with(status, **record)
        expect([progress.grade, progress.approved_on]).to eq([nil, nil])
      end
    end

    it "keeps the final exam flag for a promoted subject" do
      progress = create(:subject_progress, status: :promoted, final_exam_taken: true)
      expect(progress.reload.final_exam_taken).to be(true)
    end

    it "forgets the final exam flag when a promoted subject becomes approved" do
      progress = create(:subject_progress, status: :promoted, final_exam_taken: true)
      progress.update!(status: :approved)
      expect(progress.reload.final_exam_taken).to be(false)
    end
  end
end
