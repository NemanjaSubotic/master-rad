defmodule MsnrApiWeb.AuthView do
  use MsnrApiWeb, :view

  def render("login.json",  %{user: user, token: token, student_info: student_info}) do
    %{
      access_token: token,
      expires_in: Application.get_env(:msnr_api, :access_token_expiration),
      user: %{
        email: user.email,
        name: "#{user.first_name} #{user.last_name}",
        role: user.role.name},
      student_info: student_info
    }
  end
end
