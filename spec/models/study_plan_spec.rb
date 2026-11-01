# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudyPlan do
  it { is_expected.to belong_to(:career) }
end
