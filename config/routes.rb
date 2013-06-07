Morabeteen::Application.routes.draw do
  devise_for :users, path: ''
  devise_for :admins, path: 'admin', path_names: { sign_in: 'sign-in', sign_out: 'sign-out' }
  
  root to: 'home#index'

  match '/:controller/:action'
end
