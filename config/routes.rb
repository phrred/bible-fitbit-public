Rails.application.routes.draw do
  get 'log_reading/show'
  get 'mobile', to: "mobile#show"

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
	get "profile", to: "profile#show"
  get "contact", to: "contact#show"
  post "create_user", to: "profile#create"
  get "log_reading", to: "log_reading#show"
	get "login", to: "login#show"
  get "challenges", to: "challenges#show"
  post "create_challenge", to: "challenges#create_challenge"
  post "comparison_values", to: "dashboard#comparison_values"
  post "accept_challenge", to: "challenges#accept_challenge"
  post "reject_challenge", to: "challenges#reject_challenge"
  get "create_challenge", to: "challenges#create"
  post "search", to: "log_reading#search"
  post "future_pace", to: "dashboard#future_pace"
  post "past_pace", to: "dashboard#past_pace"
	get "dashboard", to: "dashboard#show"
	post "profile", to: "profile#update"
  post "update", to: "log_reading#update"
  post "resetBook", to: "dashboard#resetBook"
  post "resetBible", to: "dashboard#resetBible"

  resources :sessions, only: [:create, :destroy]
	resources :profile
  resource :log_reading, only: [:show]
	resources :login
  resources :mobile
  resources :challenges
  resources :contact


  root to: "login#show"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
