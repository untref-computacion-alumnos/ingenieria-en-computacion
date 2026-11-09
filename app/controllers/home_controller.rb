# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :require_study_plan

  def index; end
end
