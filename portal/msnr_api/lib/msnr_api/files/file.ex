defmodule MsnrApi.Files.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :file_path, :string
    field :group_id, :id
    field :student_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:file_path])
    |> validate_required([:file_path])
  end
end
