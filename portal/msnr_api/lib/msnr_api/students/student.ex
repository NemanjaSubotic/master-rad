defmodule MsnrApi.Students.Student do
  use Ecto.Schema
  import Ecto.Changeset
  alias MsnrApi.Accounts
  alias MsnrApi.Semesters

  schema "students" do
    field :index_number, :string
    belongs_to :user, Accounts.User
    belongs_to :semester, Semesters.Semester

    has_one :group_registrations, MsnrApi.Groups.GroupRegistration
    has_one :group, through: [:group_registrations, :group]

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:index_number, :user_id])
    |> validate_required([:user_id, :index_number])
    |> set_user()
    |> set_semester()
  end

  defp set_user(%Ecto.Changeset{changes: %{user_id: user_id}} = changeset) do
    user = Accounts.get_user!(user_id)
    changeset
    |> put_assoc(:user, user)
  end

  defp set_semester(changeset) do
    semester = Semesters.get_active_semester()
    changeset
    |> put_assoc(:semester, semester)
  end
end
