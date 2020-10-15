defmodule MsnrApiWeb.AuthController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Accounts.User
  alias MsnrApi.Repo
  import Plug.Conn, only: [put_resp_cookie: 4, put_status: 2]

  def login(conn, %{"email" => email, "password" => password}) do
    case MsnrApi.Accounts.authenticate(email, password) do
      {:ok, user} -> return_tokens conn, user
      _ -> return_unauthorized conn
    end
  end

  def refresh(conn, _) do
    user = get_user_by_token conn.req_cookies["refresh_token"]
    if user do
      return_tokens conn, user
    else
      return_unauthorized conn
    end
  end

  defp return_tokens(conn, user) do
    access_token = MsnrApiWeb.Authentication.sign(%{id: user.id, roles: user.roles})
    refresh_token = create_refresh_token user
    if refresh_token do
      conn
      |> set_refresh_cookie(refresh_token)
      |> render("login.json", %{token: access_token, user: user})
    else
      conn
      |> put_status(500)
      |> put_view(MsnrApiWeb.ErrorView)
      |> render(:"500")
    end

  end

  defp return_unauthorized(conn) do
    conn
    |> put_status(401)
    |> put_view(MsnrApiWeb.ErrorView)
    |> render(:"401")
  end

  defp create_refresh_token(user) do
    uuid = Ecto.UUID.generate()
    changeset = User.changeset_token(user, %{refresh_token: uuid})
    case Repo.update changeset do
      {:ok, user}          -> MsnrApiWeb.Authentication.sign(%{id: user.id, uuid: uuid})
      {:error, _changeset} -> nil # TO DO: log error
    end
  end

  defp get_user_by_token(token) do
    case MsnrApiWeb.Authentication.verify_access_token token do
      {:ok,  %{id: id, uuid: uuid }} -> Repo.get_by(User, [id: id, refresh_token: uuid])
      _ -> nil
    end
  end

  defp set_refresh_cookie(conn, refresh_token) do
    opts = [
      max_age: 84000, 
      secure: Application.get_env(:msnr_api, MsnrApiWeb.Endpoint, :secure_cookie)
    ]
    put_resp_cookie(conn, "refresh_token", refresh_token, opts)
  end
end
