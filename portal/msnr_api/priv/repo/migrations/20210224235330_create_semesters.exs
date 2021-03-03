defmodule MsnrApi.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters) do
      add :year, :integer, null: false
      add :ordinal_number, :integer, null: false
      add :module, :string, null: false
      add :is_active, :boolean, default: false, null: false

      timestamps()
    end

    alter table(:students) do
      add :semester_id, references(:semesters)
    end

  end
end
