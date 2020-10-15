defmodule MsnrApiWeb.Authentication do
  @salt "user_auth"

  def sign(data) do
    Phoenix.Token.sign(MsnrApiWeb.Endpoint, @salt, data)
  end

  def verify_access_token(token) do
    Phoenix.Token.verify(MsnrApiWeb.Endpoint, @salt, token, [max_age: 86400 ])
  end

  def verify_refresh_token(token) do
    Phoenix.Token.verify(MsnrApiWeb.Endpoint, @salt, token, [max_age: 86400 ])
  end

end
