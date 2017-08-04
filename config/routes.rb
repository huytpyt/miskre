Rails.application.routes.draw do
  root to: 'home#index'
  devise_for :users
  resources :shops
  resources :products
  resources :orders, only: :index do
    post 'fetch', on: :collection
  end

  post 'selectShop', to: 'home#selectShop'

  mount ShopifyApp::Engine, at: '/shopify'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
