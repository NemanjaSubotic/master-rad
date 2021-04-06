defmodule MsnrApi.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :description, :string
    field :points, :integer
    field :type, :string
    field :is_group, :boolean

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :description, :points, :is_group, :type])
    |> validate_required([:name, :description, :points, :is_group, :type])
  end
end
