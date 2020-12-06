defmodule MsnrApi.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  def student, do: "student"

  def professor, do: "professor"

  def admin, do: "admin"

  schema "roles" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_inclusion(:name, [student(), professor(), admin()])
    |> unique_constraint(:name)
  end
end
