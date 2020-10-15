defmodule MsnrApiWeb.AuthView do
  use MsnrApiWeb, :view

  def render("login.json",  %{user: user, token: token}) do
    %{
      access_token: token,
      expires_in: 600,
      user: %{
        email: user.email,
        name: "#{user.first_name} #{user.last_name}",
        roles: user.roles
      }
    }
  end
end
