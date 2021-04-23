Rails.application.routes.draw do
  # For details on the DSL available within this file, see
  # https://guides.rubyonrails.org/routing.html

  root "tasks#index"
  get "/new" => "tasks#new"
  get "/edit" => "tasks#edit"
  resource "tasks", except: [:show, :new, :edit] do
    post :complete
    post :schedule
    post :unschedule
  end

  # Any other non-XHR, HTML request should render the React client.
  get "*path", to: "application#client_index_html", constraints: lambda { |request|
    !request.xhr? && request.format.html?
  }
end
