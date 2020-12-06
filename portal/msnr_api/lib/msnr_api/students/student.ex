defmodule MsnrApi.Students.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field :index_number, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:user_id, :index_number])
    |> validate_required([:user_id, :index_number])
  end
end
