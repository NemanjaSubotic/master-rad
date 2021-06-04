defmodule MsnrApiWeb.GroupController do
  use MsnrApiWeb, :controller
  alias MsnrApi.Groups
  alias MsnrApi.Groups.Group

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, _params) do
    groups = Groups.list_groups()
    render(conn, "index.json", groups: groups)
  end

  def create(conn, %{"students" => students, "activity" => activity_id}) do
    with %{id: user_id, student_info: %{student_id: student_id}} <- conn.assigns[:user_info],
        {:ok, %Group{} = group} <- Groups.create_group(activity_id, user_id, student_id, students) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.group_path(conn, :show, group))
      |> render("show.json", group: group)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    render(conn, "show.json", group: group)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    with {:ok, %Group{} = group} <- Groups.update_group(group, group_params) do
      render(conn, "show.json", group: group)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Groups.get_group!(id)

    with {:ok, %Group{}} <- Groups.delete_group(group) do
      send_resp(conn, :no_content, "")
    end
  end
end
