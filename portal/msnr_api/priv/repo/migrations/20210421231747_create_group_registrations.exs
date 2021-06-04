defmodule MsnrApi.Repo.Migrations.CreateGroupRegistrations do
  use Ecto.Migration

  def change do
    create table(:group_registrations) do
      add :activity_id, references(:activities, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :nothing)
      add :student_id, references(:students, on_delete: :nothing)

      timestamps()
    end

    create index(:group_registrations, [:activity_id])
    create index(:group_registrations, [:group_id])
    create unique_index(:group_registrations, [:student_id])
  end
end
