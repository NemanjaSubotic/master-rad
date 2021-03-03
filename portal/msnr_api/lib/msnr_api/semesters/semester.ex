defmodule MsnrApi.Semesters.Semester do
  use Ecto.Schema
  import Ecto.Changeset

  schema "semesters" do
    field :is_active, :boolean, default: false
    field :module, :string
    field :ordinal_number, :integer
    field :year, :integer

    timestamps()
  end

  @doc false
  def changeset(semester, attrs) do
    semester
    |> cast(attrs, [:year, :ordinal_number, :module, :is_active])
    |> validate_required([:year, :ordinal_number, :module, :is_active])
  end
end
