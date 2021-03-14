defmodule MsnrApi.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias MsnrApi.Accounts
  alias MsnrApi.Semesters

  schema "groups" do
    belongs_to :creator, Accounts.User
    belongs_to :semester, Semesters.Semester
    has_many :students, MsnrApi.Students.Student

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:creator_id])
    |> validate_required([:creator_id])
    |> set_creator()
    |> set_semester()
  end


  defp set_creator(%Ecto.Changeset{changes: %{creator_id: creator_id}} = changeset) do
    creator = Accounts.get_user!(creator_id)
    changeset
    |> put_assoc(:creator, creator)
  end

  defp set_semester(changeset) do
    semester = Semesters.get_active_semester()
    changeset
    |> put_assoc(:semester, semester)
  end
end
