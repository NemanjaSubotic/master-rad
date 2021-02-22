defmodule MsnrApi.Accounts.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  defmodule Status do
    def accepted, do: "accepted"
    def rejected, do: "rejected"
    def pending, do: "pending"
  end

  schema "registrations" do
    field :email, :string
    field :first_name, :string
    field :index_number, :string
    field :last_name, :string
    field :status, :string, default: Status.pending

    timestamps()
  end

  def changeset(reg_request, attrs) do
    reg_request
    |> cast(attrs, [:email, :first_name, :last_name, :index_number, :status])
    |> validate_required([:email, :first_name, :last_name, :index_number, :status])
    |> unique_constraint(:email)
    |> unique_constraint(:index_number)
  end

  def changeset_status(reg_request, attrs) do
    reg_request
    |> cast(attrs, [:status])
    |> validate_inclusion(:status, [Status.rejected, Status.accepted, Status.pending])
  end
end
