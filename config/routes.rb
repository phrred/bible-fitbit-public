Rails.application.routes.draw do
  get 'log_reading/show'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
	get "profile", to: "profile#show"
  get "log_reading", to: "log_reading#show"
  post "search", to: "log_reading#search"

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
	resources :profile
  resource :log_reading, only: [:show]


  root to: "home#show"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
