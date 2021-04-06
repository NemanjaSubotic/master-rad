defmodule MsnrApi.Repo.Migrations.CreateV1 do
  use Ecto.Migration

  def change do
    create table(:v1) do
      add :task_id, references(:tasks, on_delete: :nothing)
      add :seminar_paper_id, references(:seminar_papers, on_delete: :nothing)
      add :file_id, references(:files, on_delete: :nothing)

      timestamps()
    end

    create index(:v1, [:task_id])
    create index(:v1, [:seminar_paper_id])
    create index(:v1, [:file_id])
  end
end
