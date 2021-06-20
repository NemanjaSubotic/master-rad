defmodule MsnrApi.Activities.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  alias MsnrApi.Tasks

  schema "activities" do
    field :ends_sec, :integer
    field :starts_sec, :integer
    field :semester_id, :id
    belongs_to :task, Tasks.Task
    belongs_to :signup, Tasks.TaskSignup

    timestamps()
  end

  @doc false
  def changeset(activit, attrs) do
    activit
    |> cast(attrs, [:starts_sec, :ends_sec, :task_id, :semester_id])
    |> validate_required([:starts_sec, :ends_sec])
  end
end
