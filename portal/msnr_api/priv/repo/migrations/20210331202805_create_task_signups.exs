defmodule MsnrApi.Repo.Migrations.CreateTaskSignups do
  use Ecto.Migration

  def change do
    create table(:task_signups) do
      add :task_id, references(:tasks, on_delete: :nothing)

      timestamps()
    end

    create index(:task_signups, [:task_id])
  end
end
