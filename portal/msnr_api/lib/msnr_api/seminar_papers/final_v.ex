defmodule MsnrApi.SeminarPapers.FinalV do
  use Ecto.Schema
  import Ecto.Changeset

  schema "final_v" do
    field :task_id, :id
    field :seminar_paper_id, :id
    field :file_id, :id

    timestamps()
  end

  @doc false
  def changeset(final_v, attrs) do
    final_v
    |> cast(attrs, [])
    |> validate_required([])
  end
end
