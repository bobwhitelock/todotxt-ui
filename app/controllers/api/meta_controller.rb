class Api::MetaController < ApplicationController
  def show
    render json: {
      data: {
        csrfToken: form_authenticity_token
      }
    }
  end
end
