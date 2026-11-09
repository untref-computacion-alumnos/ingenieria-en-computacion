# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy do
  subject(:policy) { described_class.new(user, record) }

  context "when the user acts on their own record" do
    let(:user) { build_stubbed(:user) }
    let(:record) { user }

    it "allows editing and updating" do
      expect([policy.edit?, policy.update?]).to eq([true, true])
    end
  end

  context "when the user acts on somebody else's record" do
    let(:user) { build_stubbed(:user) }
    let(:record) { build_stubbed(:user) }

    it "denies editing and updating" do
      expect([policy.edit?, policy.update?]).to eq([false, false])
    end
  end

  context "when nobody is signed in" do
    let(:user) { nil }
    let(:record) { build_stubbed(:user) }

    it "denies editing and updating" do
      expect([policy.edit?, policy.update?]).to eq([false, false])
    end
  end
end
