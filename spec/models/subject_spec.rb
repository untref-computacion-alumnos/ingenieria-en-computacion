# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subject do
  it { is_expected.to belong_to(:study_plan) }
  it { is_expected.to validate_presence_of(:name) }
end
