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

%User{} |> User.changeset_password(%{ email: "test@student", password: "test", first_name: "Test", last_name: "Testic"}) |> MsnrApi.Repo.insert!
