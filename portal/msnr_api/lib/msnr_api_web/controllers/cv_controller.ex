defmodule MsnrApiWeb.CVController do
  use MsnrApiWeb, :controller

  alias MsnrApi.CVs
  alias MsnrApi.CVs.CV
  alias MsnrApi.Files

  action_fallback MsnrApiWeb.FallbackController

  import MsnrApiWeb.Plugs.Activity
  plug :check_task, [type: "cv"]  when action in [:create]

  def index(conn, _params) do
    cv = CVs.list_cv()
    render(conn, "index.json", cv: cv)
  end

  def create(conn, %{"file" => file}) do
    filename = "test.pdf"
    with {:ok, filepath} <- Files.store_file(file.path, filename) do
      IO.inspect(filepath)
      IO.inspect(conn.params)
    end

  # def create(conn, %{"file" => file}) do
  #   with {:ok, %CV{} = cv} <- CVs.create_cv(cv_params) do
    #   conn
    #   |> put_status(:created)
    #   |> put_resp_header("location", Routes.cv_path(conn, :show, cv))
    #   |> render("show.json", cv: cv)
    # end
    send_resp(conn, :no_content, "")
  end

  def show(conn, %{"id" => id}) do
    cv = CVs.get_cv!(id)
    render(conn, "show.json", cv: cv)
  end

  def update(conn, %{"id" => id, "cv" => cv_params}) do
    cv = CVs.get_cv!(id)

    with {:ok, %CV{} = cv} <- CVs.update_cv(cv, cv_params) do
      render(conn, "show.json", cv: cv)
    end
  end

  def delete(conn, %{"id" => id}) do
    cv = CVs.get_cv!(id)

    with {:ok, %CV{}} <- CVs.delete_cv(cv) do
      send_resp(conn, :no_content, "")
    end
  end
end
