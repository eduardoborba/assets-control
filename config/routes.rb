Rails.application.routes.draw do
  resources :financial_assets do
    collection do
      patch :reorder
    end
  end
  resources :snapshots

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
