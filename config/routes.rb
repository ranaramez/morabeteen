Morabeteen::Application.routes.draw do
  devise_for :users, path: ''
  devise_for :admins, path: 'admin', path_names: { sign_in: 'sign-in', sign_out: 'sign-out' }

  resources :activities
  
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: "sessions#failure"
  match '/logout', to: 'sessions#destroy', as: 'logout'

  match "admin-dashboard", to: 'admin_dashboard#index', as: 'admin_dashboard'
  
  root to: 'home#index'

  match '/:controller/:action'
end
