defmodule MsnrApi.Repo.Migrations.CreateFinalV do
  use Ecto.Migration

  def change do
    create table(:final_v) do
      add :seminar_paper_id, references(:seminar_papers, on_delete: :nothing)
      add :file_id, references(:files, on_delete: :nothing)

      timestamps()
    end

    create index(:final_v, [:seminar_paper_id])
    create index(:final_v, [:file_id])
  end
end