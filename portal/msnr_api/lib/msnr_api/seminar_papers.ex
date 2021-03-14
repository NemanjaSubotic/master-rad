defmodule MsnrApi.SeminarPapers do
  @moduledoc """
  The SeminarPapers context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo

  alias MsnrApi.SeminarPapers.SeminarPaper

  @doc """
  Returns the list of seminar_papers.

  ## Examples

      iex> list_seminar_papers()
      [%SeminarPaper{}, ...]

  """
  def list_seminar_papers do
    Repo.all(SeminarPaper)
  end

  @doc """
  Gets a single seminar_paper.

  Raises `Ecto.NoResultsError` if the Seminar paper does not exist.

  ## Examples

      iex> get_seminar_paper!(123)
      %SeminarPaper{}

      iex> get_seminar_paper!(456)
      ** (Ecto.NoResultsError)

  """
  def get_seminar_paper!(id), do: Repo.get!(SeminarPaper, id)

  @doc """
  Creates a seminar_paper.

  ## Examples

      iex> create_seminar_paper(%{field: value})
      {:ok, %SeminarPaper{}}

      iex> create_seminar_paper(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_seminar_paper(attrs \\ %{}) do
    %SeminarPaper{}
    |> SeminarPaper.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a seminar_paper.

  ## Examples

      iex> update_seminar_paper(seminar_paper, %{field: new_value})
      {:ok, %SeminarPaper{}}

      iex> update_seminar_paper(seminar_paper, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_seminar_paper(%SeminarPaper{} = seminar_paper, attrs) do
    seminar_paper
    |> SeminarPaper.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a seminar_paper.

  ## Examples

      iex> delete_seminar_paper(seminar_paper)
      {:ok, %SeminarPaper{}}

      iex> delete_seminar_paper(seminar_paper)
      {:error, %Ecto.Changeset{}}

  """
  def delete_seminar_paper(%SeminarPaper{} = seminar_paper) do
    Repo.delete(seminar_paper)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking seminar_paper changes.

  ## Examples

      iex> change_seminar_paper(seminar_paper)
      %Ecto.Changeset{data: %SeminarPaper{}}

  """
  def change_seminar_paper(%SeminarPaper{} = seminar_paper, attrs \\ %{}) do
    SeminarPaper.changeset(seminar_paper, attrs)
  end
end
