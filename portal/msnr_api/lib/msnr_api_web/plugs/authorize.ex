defmodule MsnrApiWeb.Plugs.Authorize do
  import Plug.Conn

  def has_role(conn, options) do
    with %{role: role} <- conn.assigns[:user_info],
         ^role <- options[:role]  do
        conn
     else
      _ ->
        conn
        |> resp(:forbidden, "Forbidden")
        |> send_resp()
        |> halt()
    end
  end
end
