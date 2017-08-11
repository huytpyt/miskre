Rails.application.routes.draw do
  root to: 'home#index'
  devise_for :users
  resources :images, only: :destroy 
  resources :shops
  resources :products do
    member do
      get 'add_to_shop'
      patch 'assign'
      delete 'remove_shop'
    end
  end
  resources :orders, only: :index do
    post 'fetch', on: :collection
  end

  post 'selectShop', to: 'home#selectShop'

  post 'shipping_rates', to: 'carrier_service#shipping_rates'

  get 'carrier_service', to: 'carrier_service#index'
  get 'activate_carrier_service', to: 'carrier_service#activate'
  get 'deactivate_carrier_service', to: 'carrier_service#deactivate'

  mount ShopifyApp::Engine, at: '/shopify'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
