defmodule MsnrApi.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :starts_sec, :bigint
      add :ends_sec, :bigint
      add :semester_id, references(:semesters, on_delete: :nothing)
      add :task_id, references(:tasks, on_delete: :nothing)
      add :signup_id, references(:task_signups, on_delete: :nothing)

      timestamps()
    end

    create index(:activities, [:semester_id])
    create index(:activities, [:task_id])
    create index(:activities, [:signup_id])

    alter table(:v1) do
      add :activity_id, references(:activities, on_delete: :nothing), null: false
    end

    alter table(:final_v) do
      add :activity_id, references(:activities, on_delete: :nothing), null: false
    end

    alter table(:task_signups) do
      add :activity_id, references(:activities, on_delete: :nothing), null: false
    end

    create index(:v1, [:activity_id])
    create index(:final_v, [:activity_id])
    create index(:task_signups, [:activity_id])


  end
end
