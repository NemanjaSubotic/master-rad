defmodule MsnrApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias MsnrApi.Accounts.Role

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :is_active, :boolean
    belongs_to :role, Role
    field :refresh_token,  Ecto.UUID, autogenerate: true
    field :password_url_path, Ecto.UUID, autogenerate: true
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email])
    |> validate_required([:first_name, :last_name, :email])
    |> unique_constraint(:email)
  end

  def changeset_password(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 4)
    |> hash_password()
    |> changeset(attrs)
  end

  def changeset_role(user, %Role{} = role) do
    user
    |> put_assoc(:role, role)
  end

  def changeset_token(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:refresh_token])
    |> validate_required(:refresh_token)
    |> changeset(attrs)
  end

  defp hash_password(%Ecto.Changeset{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:hashed_password, MsnrApi.Accounts.Password.hash(password))
  end

  defp hash_password(changeset), do: changeset
end
