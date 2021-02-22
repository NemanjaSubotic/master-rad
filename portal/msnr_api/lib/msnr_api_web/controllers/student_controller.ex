defmodule MsnrApiWeb.StudentController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Students
  alias MsnrApi.Students.Student

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, _params) do
    students = Students.list_students()
    render(conn, "index.json", students: students)
  end

  def create(conn, %{"student" => student_params}) do
    with {:ok, %Student{} = student} <- Students.create_student(student_params) do
      conn
      |> put_status(:created)
      |> render("show.json", student: student)
    end
  end

  def show(conn, %{"id" => id}) do
    student = Students.get_student!(id)
    render(conn, "show.json", student: student)
  end

  def update(conn, %{"id" => id, "student" => student_params}) do
    student = Students.get_student!(id)

    with {:ok, %Student{} = student} <- Students.update_student(student, student_params) do
      render(conn, "show.json", student: student)
    end
  end
end
