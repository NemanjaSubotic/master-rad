defmodule MsnrApiWeb.SeminarPaperView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.SeminarPaperView

  def render("index.json", %{seminar_papers: seminar_papers}) do
    %{data: render_many(seminar_papers, SeminarPaperView, "seminar_paper.json")}
  end

  def render("show.json", %{seminar_paper: seminar_paper}) do
    %{data: render_one(seminar_paper, SeminarPaperView, "seminar_paper.json")}
  end

  def render("seminar_paper.json", %{seminar_paper: seminar_paper}) do
    %{id: seminar_paper.id}
  end
end
