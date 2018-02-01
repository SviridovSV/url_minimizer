Rails.application.routes.draw do
  resources :user_sessions
  resources :users
  resources :urls

  get ':short_url', to: 'urls#index'
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  root 'users#new'
end
