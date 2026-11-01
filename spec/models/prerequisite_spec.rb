# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prerequisite do
  it { is_expected.to belong_to(:subject) }
  it { is_expected.to belong_to(:required_subject).class_name("Subject") }
end
