defmodule MsnrApi.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :user_id, :integer
      add :index_number, :string

      timestamps()
    end

  end
end
