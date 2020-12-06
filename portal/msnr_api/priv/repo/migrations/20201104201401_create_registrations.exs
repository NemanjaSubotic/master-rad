defmodule MsnrApi.Repo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    create table(:registrations) do
      add :email, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :index_number, :string, null: false
      add :status, :string, null: false

      timestamps()
    end

    create unique_index(:registrations, [:email])
    create unique_index(:registrations, [:index_number])
  end
end
