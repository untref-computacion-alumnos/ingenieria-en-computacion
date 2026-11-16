# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  stale_when_importmap_changes

  private

  def after_sign_in_path_for(resource)
    wanted_path = stored_location_for(resource)
    return edit_users_study_plan_path unless resource.study_plan

    wanted_path || study_plans_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms])
  end

  def require_study_plan
    redirect_to edit_users_study_plan_path if user_signed_in? && !current_user.study_plan
  end
end
