defmodule MsnrApi.CVs.CV do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cv" do
    field :points, :integer
    field :student_id, :id
    field :file, :id
    field :file_with_commnets, :id
    field :activity_id, :id

    timestamps()
  end

  @doc false
  def changeset(cv, attrs) do
    cv
    |> cast(attrs, [:points])
    |> validate_required([:points])
  end
end
