defmodule MsnrApi.SeminarPapers.V1 do
  use Ecto.Schema
  import Ecto.Changeset

  schema "v1" do
    field :task_id, :id
    field :seminar_paper_id, :id
    field :file_id, :id

    timestamps()
  end

  @doc false
  def changeset(v1, attrs) do
    v1
    |> cast(attrs, [])
    |> validate_required([])
  end
end
