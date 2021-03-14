defmodule MsnrApi.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :creator_id, references(:users)
      add :semester_id, references(:semesters)

      timestamps()
    end

    alter table(:students) do
      add :group_id, references(:groups)
    end

  end
end
