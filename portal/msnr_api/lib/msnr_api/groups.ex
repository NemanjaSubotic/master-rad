defmodule MsnrApi.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  alias Ecto.Multi

  alias MsnrApi.Groups.Group
  alias MsnrApi.Activities.Activity
  alias MsnrApi.ActivityTypes.ActivityType
  alias MsnrApi.Assignments.Assignment
  alias MsnrApi.Students.StudentSemester
  alias MsnrApi.Students.Student

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups(semester_id) do
    from(g in Group,
      join: ss in StudentSemester,
      on: ss.semester_id == ^semester_id and g.id == ss.group_id,
      join: s in Student,
      on: s.user_id == ss.student_id,
      join: u in assoc(s, :user),
      left_join: t in assoc(g, :topic),
      preload: [topic: t, students: {s, user: u}],
      select: g
    )
    |> Repo.all()
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
  def get_group!(id) do
    from(g in Group,
      where: g.id == ^id,
      join: s in assoc(g, :students),
      join: u in assoc(s, :user),
      left_join: t in assoc(g, :topic),
      preload: [topic: t, students: {s, user: u}],
      select: g
    )
    |> Repo.one()
  end

  def get_group(id) do
    group =
      from(g in Group,
        where: g.id == ^id,
        join: s in assoc(g, :students),
        join: u in assoc(s, :user),
        left_join: t in assoc(g, :topic),
        preload: [topic: t, students: {s, user: u}],
        select: g
      )
      |> Repo.one()

    case group do
      nil -> {:error, :not_found}
      g -> {:ok, g}
    end
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(%{semester_id: semester_id, students: stundets_ids}) do
    multi_struct = Multi.new()
    |> Multi.run(:activity, fn _, _ -> get_group_activity(semester_id) end)
    |> Multi.insert(:group, %Group{})
    |> Multi.update_all(
      :students,
      fn %{group: group} ->
        from(
          s in StudentSemester,
          where: s.semester_id == ^semester_id and s.student_id in ^stundets_ids and is_nil(s.group_id),
          update: [set: [group_id: ^group.id]]
        )
      end,
      []
    )
    |> Multi.update_all(
      :assignment,
      fn %{activity: activity} ->
        from(
          a in Assignment,
          where: a.activity_id == ^activity.id and a.student_id in ^stundets_ids,
          update: [set: [completed: true]]
        )
      end,
      []
    )

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

  defp get_group_activity(semester_id) do
    group_code = MsnrApi.ActivityTypes.TypeCode.group()

    query = from(a in Activity,
      join: at in ActivityType,
      on: a.semester_id == ^semester_id and a.activity_type_id == at.id and at.code == ^group_code
    )

    case Repo.one(query) do
      nil -> {:error, :bad_request }
      activity ->
        if activity.end_date >= System.os_time(:second) do
          {:ok, activity}
        else
          {:error, :bad_request }
        end
    end

  end
end
