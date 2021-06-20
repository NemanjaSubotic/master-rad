defmodule MsnrApiWeb.Plugs.Activity do
  import Plug.Conn

  def check_task(conn, [type: type]) do
    with {activity_id, _} <- get_activity_id(conn),
      %{task: %{type: ^type}} <- MsnrApi.Activities.get_activity(activity_id) do
        conn
     else
      _ ->
        conn
        |> resp(:forbidden, "Forbidden")
        |> send_resp()
        |> halt()
    end
  end

  defp get_activity_id(conn) do
    case conn.params do
      %{"activity_id" => activity_id} -> Integer.parse(activity_id)
      _ -> :error
    end
  end
end
