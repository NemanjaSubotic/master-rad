defmodule MsnrApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  use Ecto.Schema

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :description, :string

      timestamps()
    end

    create unique_index(:roles, [:name])

    create table(:users) do
      add :email, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :hashed_password, :string
      add :is_active, :boolean, default: true
      add :role_id, references(:roles), null: false
      add :refresh_token, :uuid, null: false
      add :password_url_path, :uuid, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:refresh_token])
    create unique_index(:users, [:password_url_path])
  end
end
