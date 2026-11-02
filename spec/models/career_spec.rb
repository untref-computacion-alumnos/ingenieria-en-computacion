# frozen_string_literal: true

require "rails_helper"

RSpec.describe Career do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:study_plans).dependent(:destroy) }
end
