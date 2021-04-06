defmodule MsnrApi.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :points, :integer
      add :name, :string
      add :description, :string
      add :type, references(:task_types, column: :type, type: :string, on_delete: :nothing)
      add :is_group, :boolean, default: false

      timestamps()
    end

    create index(:tasks, [:type])
  end
end
