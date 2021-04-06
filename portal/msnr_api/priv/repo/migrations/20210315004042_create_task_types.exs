defmodule MsnrApi.Repo.Migrations.CreateTaskTypes do
  use Ecto.Migration

  def change do
    create table(:task_types, primary_key: false) do
      add :type, :string, primary_key: true

      timestamps()
    end
  end
end
