# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  resources :study_plans, only: %i[index show]
  resources :subjects, only: :show
  namespace :users do
    resource :study_plan, only: %i[edit update]
  end
end
