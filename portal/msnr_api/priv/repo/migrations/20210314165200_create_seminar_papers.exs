defmodule MsnrApi.Repo.Migrations.CreateSeminarPapers do
  use Ecto.Migration

  def change do
    create table(:seminar_papers) do
      add :group_id, references(:groups, on_delete: :nothing)
      add :topic_id, references(:topics, on_delete: :nothing)

      timestamps()
    end

    create index(:seminar_papers, [:group_id])
    create index(:seminar_papers, [:topic_id])
  end
end
