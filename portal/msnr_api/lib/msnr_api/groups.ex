defmodule MsnrApi.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  alias Ecto.Multi
  alias MsnrApi.Groups.Group
  alias MsnrApi.Groups.GroupRegistration

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups() do


    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_group(activity_id, creator_id, student_id, student_ids) do
    student_ids =
      case {is_nil(student_id), Enum.member?(student_ids, student_id) } do
        {false, false} -> [student_id | student_ids]
        _ -> student_ids
      end

    multi_struct = Multi.new
    |> Multi.insert(:group, Group.changeset(%Group{}, %{creator_id: creator_id}))
    |> Multi.run(:group_registrations, fn _repo, %{group: group} ->
      student_ids
      |> Enum.map(fn id ->
        %GroupRegistration{}
        |> GroupRegistration.changeset(%{activity_id: activity_id, group_id: group.id, student_id: id})
        |> Repo.insert!
      end)
      {:ok, :ok}
    end)


    case Repo.transaction(multi_struct) do
      {:ok, %{group: group}} -> {:ok, group}
      {:error, :group, group_changeset, _changes} -> {:error, group_changeset}
      _ ->  {:error, :bad_request}
    end
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end
end
