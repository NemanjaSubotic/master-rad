defmodule MsnrApi.Students.Student do
  use Ecto.Schema
  import Ecto.Changeset
  alias MsnrApi.Accounts
  alias MsnrApi.Accounts.User

  schema "students" do
    field :index_number, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:index_number, :user_id])
    |> validate_required([:user_id, :index_number])
    |> set_student()
  end

  defp set_student(%Ecto.Changeset{changes: %{user_id: user_id}} = changeset) do
    user = Accounts.get_user!(user_id)
    changeset
    |> put_assoc(:user, user)
  end

end
