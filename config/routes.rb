Rails.application.routes.draw do
  resources :user_sessions
  resources :users
  resources :urls do
    resources :statistics, only: [:index]
  end

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  get ':short_url', to: 'urls#fullpath'
  root 'users#new'
end
