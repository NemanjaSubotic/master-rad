defmodule MsnrApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  use Ecto.Schema

  alias MsnrApi.Accounts.Roles

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :hashed_password, :string
      add :is_active, :boolean, default: true
      add :roles, {:array, :string}, default: [Roles.student]
      add :refresh_token, :string

      timestamps
    end

    create unique_index(:users, [:email])
  end
end
