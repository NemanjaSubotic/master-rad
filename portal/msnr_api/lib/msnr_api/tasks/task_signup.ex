defmodule MsnrApi.Tasks.TaskSignup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_signups" do
    field :task_id, :id

    timestamps()
  end

  @doc false
  def changeset(task_signup, attrs) do
    task_signup
    |> cast(attrs, [])
    |> validate_required([])
  end
end
