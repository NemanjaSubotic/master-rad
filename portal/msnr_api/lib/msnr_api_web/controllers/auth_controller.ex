defmodule MsnrApiWeb.AuthController do
  use MsnrApiWeb, :controller
  import Plug.Conn
  import MsnrApi.Accounts, only: [authenticate: 2, verify_user_by_token: 2]

  alias MsnrApi.Accounts.User
  alias MsnrApi.Repo

  action_fallback MsnrApiWeb.FallbackController

  @refresh_token "refresh_token"

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- authenticate(email, password) do
      return_tokens conn, user
    end
  end

  def logout(conn, _params) do
    conn
      |> delete_resp_cookie(@refresh_token)
      |> send_resp(:no_content, "")
  end

  def refresh(conn, _params) do
    with {:ok, user}  <- get_user_by_token conn.req_cookies[@refresh_token] do
      return_tokens conn, user
    end
  end

  defp return_tokens(conn, user) do
    access_token = MsnrApiWeb.Authentication.sign(%{id: user.id, role: user.role.name})
    with  {:ok, refresh_token } <- create_refresh_token user do
      conn
      |> set_refresh_cookie(refresh_token)
      |> render("login.json", %{token: access_token, user: user})
    end
  end

  defp create_refresh_token(user) do
    uuid = Ecto.UUID.generate()
    changeset = User.changeset_token(user, %{refresh_token: uuid})
    case Repo.update changeset do
      {:ok, user}         -> {:ok, signed_token(user, uuid)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp signed_token(user, uuid), do: MsnrApiWeb.Authentication.sign(%{id: user.id, uuid: uuid})

  defp get_user_by_token(token) do
    case MsnrApiWeb.Authentication.verify_refresh_token token do
      {:ok,  %{id: id, uuid: uuid }} -> verify_user_by_token id, uuid
      _ -> {:error, :unauthorized}
    end
  end

  defp set_refresh_cookie(conn, refresh_token) do
    opts = [
      max_age: Application.get_env(:msnr_api, :refresh_token_expiration),
      secure: Application.get_env(:msnr_api, :secure_cookie)
    ]
    put_resp_cookie(conn, @refresh_token, refresh_token, opts)
  end
end
