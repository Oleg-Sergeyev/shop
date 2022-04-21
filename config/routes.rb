Rails.application.routes.draw do
  root 'catalogs#index'
  get "/uploads" => "uploads#index"
  post "/uploads" => "uploads#create"
  resources :catalogs
  resources :products
  resources :catalogs do
    resources :products
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
