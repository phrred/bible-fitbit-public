Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
	get "profile", to: "profile#show"

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
	resources :profile


  root to: "home#show"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
