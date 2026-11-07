# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  describe "#after_sign_in_path_for" do
    let(:user) { create(:user) }

    it "goes to the plans list when the user wanted no page in particular" do
      expect(controller.send(:after_sign_in_path_for, user)).to eq(study_plans_path)
    end

    it "goes back to the page the user wanted" do
      controller.session["user_return_to"] = "/subjects/1"
      expect(controller.send(:after_sign_in_path_for, user)).to eq("/subjects/1")
    end

    it "forgets the wanted page after using it" do
      controller.session["user_return_to"] = "/subjects/1"
      controller.send(:after_sign_in_path_for, user)
      expect(controller.send(:after_sign_in_path_for, user)).to eq(study_plans_path)
    end
  end
end
