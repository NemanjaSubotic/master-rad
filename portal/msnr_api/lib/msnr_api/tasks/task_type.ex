defmodule MsnrApi.Tasks.TaskType do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:type, :string, autogenerate: false}
  schema "task_types" do
    timestamps()
  end

  @doc false
  def changeset(task_type, attrs) do
    task_type
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
