defmodule MsnrApi.Repo.Migrations.CreateSeminarPapers do
  use Ecto.Migration

  def change do
    create table(:seminar_papers) do
      add :group_id, references(:groups, on_delete: :nothing)
      add :topic_id, references(:topics, on_delete: :nothing)
      add :v1, references(:files, on_delete: :nothing)
      add :final, references(:files, on_delete: :nothing)

      timestamps()
    end

    create index(:seminar_papers, [:group_id])
    create index(:seminar_papers, [:topic_id])
    create index(:seminar_papers, [:v1])
    create index(:seminar_papers, [:final])
  end
end
