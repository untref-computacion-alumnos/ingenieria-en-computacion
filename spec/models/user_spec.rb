# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  describe "validations" do
    it "is valid with an email and a password" do
      expect(build(:user)).to be_valid
    end

    it "requires an email" do
      user = build(:user, email: "")
      user.validate
      expect(user.errors).to be_of_kind(:email, :blank)
    end

    it "rejects an email that is already taken, ignoring case" do
      create(:user, email: "ana@example.com")
      user = build(:user, email: "ANA@example.com")
      user.validate
      expect(user.errors).to be_of_kind(:email, :taken)
    end

    it "rejects a password shorter than 10 characters" do
      user = build(:user, password: "short-123")
      user.validate
      expect(user.errors).to be_of_kind(:password, :too_short)
    end

    it "accepts a password of exactly 10 characters" do
      expect(build(:user, password: "1234567890")).to be_valid
    end
  end

  describe "study plan" do
    it { is_expected.to belong_to(:study_plan).optional }

    it "is valid without a study plan, like a brand new account" do
      expect(build(:user, study_plan: nil)).to be_valid
    end

    it "is valid with a study plan" do
      expect(build(:user, :with_study_plan)).to be_valid
    end

    it "requires a study plan when it is being chosen" do
      user = build(:user, study_plan: nil)
      user.validate(:plan_selection)
      expect(user.errors).to be_of_kind(:study_plan, :blank)
    end

    it "accepts a study plan when it is being chosen" do
      expect(build(:user, :with_study_plan).valid?(:plan_selection)).to be(true)
    end
  end

  describe "roles" do
    it "gives every new user the student role" do
      expect(create(:user)).to have_role(:student)
    end

    it "does not give a second student role when the user is saved again" do
      user = create(:user)
      expect { user.update!(email: "other@example.com") }.not_to change(user.roles, :count)
    end

    it "does not make the user a teacher or an admin" do
      user = create(:user)
      expect(user.roles.pluck(:name)).to eq(["student"])
    end
  end

  describe "subject progress" do
    let(:user) { create(:user) }
    let(:subject_record) { create(:subject) }

    it { is_expected.to have_many(:subject_progresses).dependent(:destroy) }

    describe "#status_for" do
      it "is pending when the user never marked the subject" do
        expect(user.status_for(subject_record)).to eq("pending")
      end

      it "returns the status the user marked" do
        create(:subject_progress, user: user, subject: subject_record, status: :regular)
        expect(user.status_for(subject_record)).to eq("regular")
      end

      it "ignores what other users marked" do
        create(:subject_progress, subject: subject_record, status: :approved)
        expect(user.status_for(subject_record)).to eq("pending")
      end
    end

    describe "#progress_statuses" do
      it "maps the id of each marked subject to its status" do
        create(:subject_progress, user: user, subject: subject_record, status: :approved)
        expect(user.progress_statuses[subject_record.id]).to eq("approved")
      end

      it "answers pending for a subject that was never marked" do
        expect(user.progress_statuses[subject_record.id]).to eq("pending")
      end
    end
  end
end
