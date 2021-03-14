defmodule MsnrApi.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string, null: false
      add :available, :boolean, default: false, null: false

      timestamps()
    end

  end
end
