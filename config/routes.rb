Morabeteen::Application.routes.draw do
  devise_for :users, path: ''
  devise_for :admins, path: 'admin', path_names: { sign_in: 'sign-in', sign_out: 'sign-out' }

  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: "sessions#failure"
  match '/logout', to: 'sessions#destroy', as: 'logout'
  
  root to: 'home#index'

  match '/:controller/:action'
end
