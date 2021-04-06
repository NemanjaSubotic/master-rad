defmodule MsnrApi.Activities.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :ends_sec, :integer
    field :starts_sec, :integer
    field :semester_id, :id
    field :task_id, :id
    field :signup_id, :id

    timestamps()
  end

  @doc false
  def changeset(activit, attrs) do
    activit
    |> cast(attrs, [:starts_sec, :ends_sec, :task_id, :semester_id])
    |> validate_required([:starts_sec, :ends_sec])
  end
end
