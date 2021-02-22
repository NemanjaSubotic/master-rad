# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MsnrApi.Repo.insert!(%MsnrApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias MsnrApi.Accounts.User
alias MsnrApi.Accounts.Role

student = %Role{} |> Role.changeset(%{name: Role.student, description: "Student"}) |> MsnrApi.Repo.insert!
professor = %Role{} |> Role.changeset(%{name: Role.professor, description: "Profesor"}) |> MsnrApi.Repo.insert!
admin = %Role{} |> Role.changeset(%{name: Role.admin, description: "Administrator"}) |> MsnrApi.Repo.insert!

%User{} |> User.changeset_password(%{ email: "test@student", password: "test", first_name: "Test", last_name: "Student"}) |> User.changeset_role(student) |> MsnrApi.Repo.insert!
%User{} |> User.changeset_password(%{ email: "test@professor", password: "test", first_name: "Test", last_name: "Profesor"}) |> User.changeset_role(professor) |> MsnrApi.Repo.insert!
%User{} |> User.changeset_password(%{ email: "test@admin", password: "test", first_name: "Test", last_name: "Admin"}) |> User.changeset_role(admin) |> MsnrApi.Repo.insert!
