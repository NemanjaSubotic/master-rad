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
  def changeset_student_file(file, attrs) do
    file
    |> cast(attrs, [:file_path, :student_id, :user_id])
    |> validate_required([:file_path, :student_id, :user_id])
  end

  def changeset_group_file(file, attrs) do
    file
    |> cast(attrs, [:file_path, :group_id, :user_id])
    |> validate_required([:file_path, :group_id, :user_id])
  end
end
