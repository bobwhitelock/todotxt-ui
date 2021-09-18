require "rails_helper"
require "support/api_test_utils"

RSpec.describe "/api/meta" do
  include ApiTestUtils

  describe "GET /api/meta" do
    it "returns expected data" do
      mock_auth_config
      allow_any_instance_of(
        Api::MetaController
      ).to receive(
        :form_authenticity_token
      ).and_return("my_csrf_token")

      get "/api/meta", headers: basic_auth_header

      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body).deep_symbolize_keys
      expect(response_json).to eq({
        data: {
          csrfToken: "my_csrf_token"
        }
      })
    end
  end
end
