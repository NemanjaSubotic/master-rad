defmodule MsnrApi.CVs do
  @moduledoc """
  The CVs context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  # alias Ecto.Multi

  alias MsnrApi.CVs.CV
  # alias MsnrApi.Files.File

  @doc """
  Returns the list of cv.

  ## Examples

      iex> list_cv()
      [%CV{}, ...]

  """
  def list_cv do
    Repo.all(CV)
  end

  @doc """
  Gets a single cv.

  Raises `Ecto.NoResultsError` if the Cv does not exist.

  ## Examples

      iex> get_cv!(123)
      %CV{}

      iex> get_cv!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cv!(id), do: Repo.get!(CV, id)

  @doc """
  Creates a cv.

  ## Examples

      iex> create_cv(%{field: value})
      {:ok, %CV{}}

      iex> create_cv(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cv(attrs) do
    # file_changeset = File.changeset_student_file(%File{}, params)
    # Multi.new()
    #   |> Multi.insert(:file, file_changeset)
    # # Multi.new()
    # # |> Multi.insert(:user, user_changeset)
    # # |> Multi.run(:student, fn _repo, %{user: user} ->
    # #     %Student{}
    # #     |> Student.changeset(%{user_id: user.id, index_number: registration.index_number})
    # #     |> Repo.insert
    # # end)

    %CV{}
    |> CV.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cv.

  ## Examples

      iex> update_cv(cv, %{field: new_value})
      {:ok, %CV{}}

      iex> update_cv(cv, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cv(%CV{} = cv, attrs) do
    cv
    |> CV.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cv.

  ## Examples

      iex> delete_cv(cv)
      {:ok, %CV{}}

      iex> delete_cv(cv)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cv(%CV{} = cv) do
    Repo.delete(cv)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cv changes.

  ## Examples

      iex> change_cv(cv)
      %Ecto.Changeset{data: %CV{}}

  """
  def change_cv(%CV{} = cv, attrs \\ %{}) do
    CV.changeset(cv, attrs)
  end
end
