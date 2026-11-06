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
end
