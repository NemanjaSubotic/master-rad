defmodule MsnrApi.Assignments.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assignments" do
    field :comment, :string
    field :completed, :boolean, default: false
    field :grade, :integer
    field :student_id, :id
    field :group_id, :id
    field :activity_id, :id
    field :related_topic_id, :id

    timestamps()
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:activity_id])
    |> validate_required([:activity_id])
  end

  def signup_changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:completed])
    |> validate_required([:completed])
  end
end
