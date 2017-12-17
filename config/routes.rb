Rails.application.routes.draw do
  get 'log_reading/show'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
	get "profile", to: "profile#show"
  post "create_user", to: "profile#create"
  get "log_reading", to: "log_reading#show"
  get "challenges", to: "challenges#show"
  post "create_challenge", to: "challenges#create"
  post "search", to: "log_reading#search"
	get "dashboard", to: "dashboard#show"
	post "profile", to: "profile#update"
  post "update", to: "log_reading#update"
  post "resetBook", to: "log_reading#resetBook"
  post "resetBible", to: "log_reading#resetBible"

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
	resources :profile
  resource :log_reading, only: [:show]
  resources :challenges


  root to: "home#show"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
