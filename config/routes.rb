Rails.application.routes.draw do
  resources :financial_assets do
    collection do
      patch :reorder
    end
  end
  resources :snapshots do
    collection do
      get :prefill
      get :fetch_rate
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
