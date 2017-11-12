Rails.application.routes.draw do

  resources 'shipping_setings', only: [:index] do 
    collection do
      get "update_carrier_service/:shop_id", to: "shipping_setings#update_carrier_service", as: "update_carrier"
      get ":shipping_type_id/setting", to: "shipping_setings#setting", as: "setting"
      get ":shipping_type_id/setting/new", to: "shipping_setings#new", as: "new"
      post ":shipping_type_id/setting/create", to: "shipping_setings#create", as: "create"
      get ":shipping_type_id/setting/change_status", to: "shipping_setings#change_status", as: "change_status"
      get ":shipping_type_id/setting/:id", to: "shipping_setings#edit", as: "edit"
      patch ":shipping_type_id/setting/:id", to: "shipping_setings#update", as: "update"
      delete ":shipping_type_id/setting/:id", to: "shipping_setings#destroy", as: "delete"
    end
  end

  resources :nations do
    collection do 
      get 'sync_shipping', to: "nations#sync_shipping"
      get 'sync_nation/:nation_id', to: "nations#sync_nation", as: "sync_nation"
    end 
    resources :shipping_types do
      resources :detail_shipping_types
      resources :detail_no_handlings
    end
  end
  resources :request_products

  resources :invite_people, only: [:index] do 
    collection do 
      post "invite"
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'home#index'
  resources :users, only: [:index, :update]
  devise_scope :user do
    get 'sign_up' => 'users/registrations#new', as: :new_user_registration
    post 'sign_up/conf' => 'users/registrations#confirm', as: :user_confirm_registration
    post 'sign_up' => 'users/registrations#create', as: :user_registration
    patch 'sign_up' => 'users/registrations#update', as: :user_registration_update
    get 'sign_up/comp' => 'users/registrations#comp', as: :user_complete_registration
    get 'sign_up/mail_comp' => 'users/registrations#mail_comp', as: :user_mail_complete_registration
    get 'forgetpass' => 'users/passwords#new', as: :new_user_password
    post 'forgetpass' => 'users/passwords#create', as: :user_password
    get 'forgetpass/send_comp' => 'users/passwords#send_comp', as: :send_comp

    get 'forgetpass/set_pass' => 'users/passwords#edit', as: :edit_user_password
    patch 'forgetpass' => 'users/passwords#update', as: :user_password_patch
    put 'forgetpass' => 'users/passwords#update', as: :user_password_put
    get 'forgetpass/set_comp' => 'users/passwords#set_comp', as: :set_comp
  
    get 'logout' => 'users/sessions#logout', as: :logout
    get 'signout' => 'users/sessions#destroy', as: :user_signout
    get 'sign_in' => 'users/sessions#new', as: :new_user_session
    post 'sign_in' => 'users/sessions#create', as: :user_session
  end
  devise_for :users, skip: [:sessions, :registrations, :passwords, :confirmations]

  resources :shippings
  resources :images, only: :destroy

  resources :payments, only: [:index, :new, :create] do
    collection do 
      get "edit", to: "payments#edit", as: "edit"
      post "update", to: "payments#update", as: "update"
      get "remove", to: "payments#remove", as: "remove"
    end
  end
  resources :shops do
    collection do
      get ":id/supply_orders_unfulfilled", to: "shops#supply_orders_unfulfilled", as: "reports"
      get ":id/reports", to: "shops#reports", as: "report_view"
    end
    get "bundle_manager", to: "shops#bundle_manager", as: "bundle_manager"
    get "new_bundle", to: "shops#new_bundle", as: "new_bundle"
    post "create_bundle", to: "products#create_bundle", as: "create_bundle"
    get ":supply_id/shipping", to: "shops#shipping", as: "shipping"
    patch "global_price_setting", to: "shops#global_price_setting", as: "global_price_setting"
    get "change_price_option", to: "shops#change_price_option", as: "change_price_option"
    member do
      get :user_products
    end
  end
  resources :supplies, only: [:edit, :update, :destroy] do
    get "edit_variant/:variant_id", to: "supplies#edit_variant", as: "edit_variant"
    patch "edit_variant/:variant_id", to: "supplies#update_variant", as: "update_variant"
    post 'upload_image_url', on: :member
  end
  resources :reports do
    collection do
      get "product_orders_unfulfilled", to: "reports#product_orders_unfulfilled"
    end
  end
  resources :products do
    collection do
      get ":request_id/:user_id/new_product", to: "products#new", as: "new_user_product"

      get "new_bundle", to: "products#new_bundle"
      post "create_bundle", to: "products#create_bundle"
    end
    patch "update_bundle", to: "products#update_bundle"
    
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
    collection do
      get 'fetch_orders', to: "orders#fetch_orders", as: "fetch_orders"
    end
  end

  resources :billings do
    collection { post :import }
  end

  resources :user_products do
    member do
      post :approve
    end
  end

  post 'selectShop', to: 'home#selectShop'

  post 'shipping_rates', to: 'carrier_service#shipping_rates'

  get 'carrier_service', to: 'carrier_service#index'
  post 'find_ship_cost', to: 'carrier_service#lookup'
  get 'activate_carrier_service', to: 'carrier_service#activate'
  get 'deactivate_carrier_service', to: 'carrier_service#deactivate'

  namespace :api, defaults: {format: :json}, :except => [:edit, :new] do
    resource :product, only: :index do
      get :profit_calculator
      collection do
        post 'sync_products/:shop_id', to: 'products#sync_products', as: :sync_products_from_shop
        post 'user_products/:id/request', to: 'products#request_user_product', as: :request_user_product
      end
    end

    # Routes for API
    namespace :v1 do
      resource :test, only: :show
      resources :users, defaults: {scope: :users}, only: :show do
        scope module: 'resource', as: :users do
          collection do
            resource :session
          end
        end
      end
    end
  end

  mount ShopifyApp::Engine, at: '/shopify'

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.staff? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
