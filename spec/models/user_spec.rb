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
end
