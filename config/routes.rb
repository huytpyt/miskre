Rails.application.routes.draw do
  devise_for :users

  # devise_scope :user do
  #   get 'sign_in', to: 'devise/sessions#new'
  # end
   
  resources :products
  root to: 'home#index'
  post 'selectShop', to: 'home#selectShop'
  mount ShopifyApp::Engine, at: '/shopify'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
