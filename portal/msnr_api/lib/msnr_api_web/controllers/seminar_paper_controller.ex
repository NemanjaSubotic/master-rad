defmodule MsnrApiWeb.SeminarPaperController do
  use MsnrApiWeb, :controller

  alias MsnrApi.SeminarPapers
  alias MsnrApi.SeminarPapers.SeminarPaper

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, _params) do
    seminar_papers = SeminarPapers.list_seminar_papers()
    render(conn, "index.json", seminar_papers: seminar_papers)
  end

  def create(conn, %{"seminar_paper" => seminar_paper_params}) do
    with {:ok, %SeminarPaper{} = seminar_paper} <- SeminarPapers.create_seminar_paper(seminar_paper_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.seminar_paper_path(conn, :show, seminar_paper))
      |> render("show.json", seminar_paper: seminar_paper)
    end
  end

  def show(conn, %{"id" => id}) do
    seminar_paper = SeminarPapers.get_seminar_paper!(id)
    render(conn, "show.json", seminar_paper: seminar_paper)
  end

  def update(conn, %{"id" => id, "seminar_paper" => seminar_paper_params}) do
    seminar_paper = SeminarPapers.get_seminar_paper!(id)

    with {:ok, %SeminarPaper{} = seminar_paper} <- SeminarPapers.update_seminar_paper(seminar_paper, seminar_paper_params) do
      render(conn, "show.json", seminar_paper: seminar_paper)
    end
  end

  def delete(conn, %{"id" => id}) do
    seminar_paper = SeminarPapers.get_seminar_paper!(id)

    with {:ok, %SeminarPaper{}} <- SeminarPapers.delete_seminar_paper(seminar_paper) do
      send_resp(conn, :no_content, "")
    end
  end
end
