Rails.application.routes.draw do
  # For details on the DSL available within this file, see
  # https://guides.rubyonrails.org/routing.html

  root 'tasks#index'
  get '/new' => 'tasks#new'
  get '/edit' => 'tasks#edit'
  resource 'tasks', except: [:show, :new, :edit] do
    post :complete
  end
end
