defmodule MsnrApiWeb.StudentView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.StudentView

  def render("index.json", %{students: students}) do
    %{data: render_many(students, StudentView, "student.json")}
  end

  def render("show.json", %{student: student}) do
    %{data: render_one(student, StudentView, "student.json")}
  end

  def render("student.json", %{student: student}) do
    %{id: student.id,
      first_name: student.first_name,
      last_name: student.last_name,
      email: student.email,
      index_number: student.index_number}
  end
end
