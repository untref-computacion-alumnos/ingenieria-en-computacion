# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || study_plans_path
  end
end
