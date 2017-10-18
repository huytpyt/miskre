Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'home#index'
  devise_for :users
  resources :images, only: :destroy

  resources :shops do
    collection do
      get ":id/supply_orders_unfulfilled", to: "shops#supply_orders_unfulfilled", as: "reports"
      get ":id/reports", to: "shops#reports", as: "report_view"
    end
    get ":supply_id/shipping", to: "shops#shipping", as: "shipping"
  end
  resources :supplies, only: [:edit, :update, :destroy] do
    post 'upload_image_url', on: :member
  end
  resources :reports do
    collection do
      get "product_orders_unfulfilled", to: "reports#product_orders_unfulfilled"
    end
  end
  resources :products do
    member do
      get 'report'
      get 'tracking_product'
      get 'add_to_shop'
      patch 'assign'
      post 'upload_image_url'
    end
    resources :options
    resources :variants do
      get 'reload', on: :collection
      post 'upload_image_url', on: :member
    end
    get 'purchases', on: :collection
    get "shipping"
  end

  resources :orders, only: [:index, :show] do
    resources :fulfillments, only: [:new, :create]
    get 'fetch', on: :collection
  end

  resources :billings do
    collection { post :import }
  end

  post 'selectShop', to: 'home#selectShop'

  post 'shipping_rates', to: 'carrier_service#shipping_rates'

  get 'carrier_service', to: 'carrier_service#index'
  get 'find_ship_cost', to: 'carrier_service#lookup'
  get 'activate_carrier_service', to: 'carrier_service#activate'
  get 'deactivate_carrier_service', to: 'carrier_service#deactivate'

  mount ShopifyApp::Engine, at: '/shopify'

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.staff? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
