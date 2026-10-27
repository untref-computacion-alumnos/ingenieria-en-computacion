# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { instance_double(User) }
  let(:record) { Object.new }

  it "exposes user and record" do
    expect(policy).to have_attributes(user: user, record: record)
  end

  %i[index? show? create? new? update? edit? destroy?].each do |action|
    it "denies #{action} due to default" do
      expect(policy.public_send(action)).to be(false)
    end
  end

  describe ApplicationPolicy::Scope do
    it "requires defining resolve in the subclasses" do
      scope = described_class.new(user, User)

      expect { scope.resolve }.to raise_error(NoMethodError, /You must define #resolve/)
    end
  end
end
