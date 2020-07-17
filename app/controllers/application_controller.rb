class ApplicationController < ActionController::Base
  http_basic_authenticate_with(
    name: Figaro.env.AUTH_USER!,
    password: Figaro.env.AUTH_PASSWORD!,
  )
end
