defmodule MsnrApi.Groups.GroupRegistration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_registrations" do
    belongs_to :activity, MsnrApi.Activities.Activity
    belongs_to :group, MsnrApi.Groups.Group
    belongs_to :student, MsnrApi.Students.Student

    timestamps()
  end

  @doc false
  def changeset(group_registration, attrs) do
    group_registration
    |> cast(attrs, [:activity_id, :group_id, :student_id])
    |> validate_required([:activity_id, :group_id, :student_id])
  end
end
