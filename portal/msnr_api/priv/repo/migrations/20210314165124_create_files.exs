defmodule MsnrApi.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :file_path, :string
      add :group_id, references(:groups, on_delete: :nothing)
      add :student_id, references(:students, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:files, [:group_id])
    create index(:files, [:student_id])
    create index(:files, [:user_id])
  end
end
