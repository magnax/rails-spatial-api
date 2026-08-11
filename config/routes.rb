Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :places, only: :index
      resources :streets, only: :index
      get 'places/:amenity', to: 'places#search'
      get 'places/:place_type/:place_name', to: 'places#search'
    end
  end

  root "welcome#index"
end
