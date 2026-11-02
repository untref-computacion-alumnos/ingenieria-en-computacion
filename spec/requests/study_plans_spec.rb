# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Study plans" do
  describe "GET /study_plans" do
    it "lists the plans newest first" do
      create(:study_plan, year: 2013)
      create(:study_plan, year: 2022)
      get study_plans_path
      expect(response.body).to match(/2022.*2013/m)
    end
  end
end
