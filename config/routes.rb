Rails.application.routes.draw do
  # get 'user_sessions/new'

  # get 'user_sessions/create'

  # get 'user_sessions/destroy'
  resources :user_sessions
  resources :users

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  root 'users#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
