Rails.application.routes.draw do
  # For details on the DSL available within this file, see
  # https://guides.rubyonrails.org/routing.html

  namespace :api do
    get "/tasks" => "tasks#index"
    post "/tasks" => "tasks#update"
  end

  # Any other non-XHR, HTML request should render the React client.
  get "*path", to: "application#client_index_html", constraints: lambda { |request|
    !request.xhr? && request.format.html?
  }
end
