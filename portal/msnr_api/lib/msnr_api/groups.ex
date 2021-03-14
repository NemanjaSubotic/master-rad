defmodule MsnrApi.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  alias Ecto.Multi
  alias MsnrApi.Groups.Group
  alias MsnrApi.Semesters.Semester
  alias MsnrApi.Students.Student

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

  def create_group(creator_id, creator_role, student_ids) do
    student_ids =
      if creator_role == MsnrApi.Accounts.Role.student do
        add_student_id(creator_id, student_ids)
      else
        student_ids
      end

    multi_struct = Multi.new
    |> Multi.insert(:group, Group.changeset(%Group{}, %{creator_id: creator_id}))
    |> Multi.run(:students, fn _repo, %{group: group} ->
        students = from s in "students",
                    where: s.id in ^student_ids and is_nil(s.group_id)
        {count, _} = Repo.update_all(students, set: [group_id: group.id]);

        if count > 0 and count == length(student_ids) do
          {:ok , count}
        else
          {:error, :bad_request}
        end
      end)

      case Repo.transaction(multi_struct) do
        {:ok, %{group: group}} -> {:ok, group}
        {:error, :group, group_changeset, _changes} ->  {:error, group_changeset}
        _ ->  {:error, :bad_request}
      end
  end

  defp add_student_id(creator_id, student_ids) do
    query =
      from stud in Student,
      join: sem in Semester,
      on: stud.user_id == ^creator_id and sem.is_active and stud.semester_id == sem.id,
      select: stud.id

    with [id] <- Repo.all(query) do
      if Enum.member?(student_ids, id) do
        student_ids
      else
        [id | student_ids]
      end
    else
      _ -> []
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
