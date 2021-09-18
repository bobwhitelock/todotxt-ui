module ApiTestUtils
  def mock_auth_config
    allow(Figaro.env).to receive("AUTH_USER!").and_return(test_username)
    allow(Figaro.env).to receive("AUTH_PASSWORD!").and_return(test_password)
  end

  def basic_auth_header
    {Authorization: "Basic #{Base64.encode64("#{test_username}:#{test_password}")}"}
  end

  private

  def test_username
    "user"
  end

  def test_password
    "password"
  end
end
