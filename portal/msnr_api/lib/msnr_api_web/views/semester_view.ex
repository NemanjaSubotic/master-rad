defmodule MsnrApiWeb.SemesterView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.SemesterView

  def render("index.json", %{semesters: semesters}) do
    %{data: render_many(semesters, SemesterView, "semester.json")}
  end

  def render("show.json", %{semester: semester}) do
    %{data: render_one(semester, SemesterView, "semester.json")}
  end

  def render("semester.json", %{semester: semester}) do
    %{id: semester.id,
      year: semester.year,
      ordinal_number: semester.ordinal_number,
      module: semester.module,
      is_active: semester.is_active}
  end
end
