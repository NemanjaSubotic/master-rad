defmodule MsnrApi.SeminarPapers.SeminarPaper do
  use Ecto.Schema
  import Ecto.Changeset

  schema "seminar_papers" do
    field :group_id, :id
    field :topic_id, :id

    timestamps()
  end

  @doc false
  def changeset(seminar_paper, attrs) do
    seminar_paper
    |> cast(attrs, [])
    |> validate_required([])
  end
end
