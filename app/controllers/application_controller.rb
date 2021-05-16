class ApplicationController < ActionController::Base
  # XXX Insecure, remove/change before deploy!
  skip_before_action :verify_authenticity_token

  http_basic_authenticate_with(
    name: Figaro.env.AUTH_USER!,
    password: Figaro.env.AUTH_PASSWORD!,
    except: :client_index_html
  )

  def client_index_html
    render file: Rails.root.join("public", "index.html")
  end
end
