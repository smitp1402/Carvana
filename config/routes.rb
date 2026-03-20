Rails.application.routes.draw do
  devise_for :users

  root "vehicles#index"

  resources :vehicles, only: [ :index, :show ]

  resources :onboarding_applications, only: [ :create, :show ] do
    member do
      get  "step/:step", to: "onboarding_applications#step", as: :step
      patch "step/:step", to: "onboarding_applications#update_step", as: :update_step
    end
  end

  resources :document_uploads, only: [ :create ] do
    collection do
      post :scan
    end
  end

  resources :chat_messages, only: [ :create ]

  get "up" => "rails/health#show", as: :rails_health_check
end
