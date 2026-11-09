# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def after_sign_in_path_for(resource)
    wanted_path = stored_location_for(resource)
    return edit_users_study_plan_path if resource.study_plan.nil?

    wanted_path || study_plans_path
  end

  def require_study_plan
    redirect_to edit_users_study_plan_path if user_signed_in? && current_user.study_plan.nil?
  end
end
