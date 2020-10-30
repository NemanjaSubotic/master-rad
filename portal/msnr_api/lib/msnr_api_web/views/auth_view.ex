defmodule MsnrApiWeb.AuthView do
  use MsnrApiWeb, :view

  def render("login.json",  %{user: user, token: token}) do
    %{
      access_token: token,
      expires_in: Application.get_env(:token, :access_token_expiration),
      user: %{
        email: user.email,
        name: "#{user.first_name} #{user.last_name}",
        roles: user.roles
      }
    }
  end
end
