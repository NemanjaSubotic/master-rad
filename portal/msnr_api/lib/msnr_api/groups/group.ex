defmodule MsnrApi.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias MsnrApi.Accounts
  alias MsnrApi.Semesters

  schema "groups" do
    belongs_to :creator, Accounts.User
    belongs_to :semester, Semesters.Semester
    has_many :group_registrations, MsnrApi.Groups.GroupRegistration
    has_many :students, through: [:group_registrations, :student]


    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:creator_id])
    |> validate_required([:creator_id])
    |> set_semester()
  end


  defp set_semester(changeset) do
    semester = Semesters.get_active_semester()
    changeset
    |> put_assoc(:semester, semester)
  end
end
