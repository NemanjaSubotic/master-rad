defmodule MsnrApiWeb.Plugs do
  import Plug.Conn

  def set_user_info(conn, _opts) do
    with [auth_header] <- get_req_header(conn,"authorization"),
      "Bearer " <> token <- auth_header,
      {:ok, payload} <- MsnrApiWeb.Authentication.verify_access_token token do

        assign(conn, :user_info, payload)
    else
      _ ->
        assign(conn, :user_info, nil)
    end
  end
end
