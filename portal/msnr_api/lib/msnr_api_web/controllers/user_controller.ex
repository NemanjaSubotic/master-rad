defmodule MsnrApiWeb.UserController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Accounts
  alias MsnrApi.Accounts.User

  action_fallback MsnrApiWeb.FallbackController

  def show(conn, %{"id" => uuid}) do
    user = Accounts.get_user_by_url!(uuid)
    render(conn, "user_id.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => %{"email" => email, "password" => password}}) do
    with {:ok, user} <- Accounts.verify_user_by_email(id, email),
         {:ok, %User{} = user} <- Accounts.set_password(user, password) do

          render(conn, "user_id.json", user: user)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   student = Students.get_student!(id)

  #   with {:ok, %Student{}} <- Students.delete_student(student) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
