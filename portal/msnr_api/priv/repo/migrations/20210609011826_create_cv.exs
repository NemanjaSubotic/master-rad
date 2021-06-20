defmodule MsnrApi.Repo.Migrations.CreateCv do
  use Ecto.Migration

  def change do
    create table(:cv) do
      add :points, :integer
      add :student_id, references(:students, on_delete: :nothing)
      add :file, references(:files, on_delete: :nothing)
      add :file_with_commnets, references(:files, on_delete: :nothing)
      add :activity_id, references(:activities, on_delete: :nothing)

      timestamps()
    end

    create index(:cv, [:student_id])
    create index(:cv, [:file])
    create index(:cv, [:file_with_commnets])
    create index(:cv, [:activity_id])
  end
end
