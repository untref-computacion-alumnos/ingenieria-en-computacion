# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectProgressPolicy do
  subject(:policy) { described_class.new(user, progress) }

  let(:progress) { build_stubbed(:subject_progress, user: owner) }
  let(:owner) { build_stubbed(:user) }

  context "when the user acts on their own progress" do
    let(:user) { owner }

    it "allows updating" do
      expect(policy.update?).to be(true)
    end
  end

  context "when the user acts on somebody else's progress" do
    let(:user) { build_stubbed(:user) }

    it "denies updating" do
      expect(policy.update?).to be(false)
    end
  end

  context "when nobody is signed in" do
    let(:user) { nil }

    it "denies updating" do
      expect(policy.update?).to be(false)
    end
  end
end
