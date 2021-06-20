defmodule MsnrApi.Files do
  @moduledoc """
  The Files context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo

  alias MsnrApi.Files.File, as: MsnrFile

  @files_store "/Users/nemanja/repos/master-rad/portal/msnr_api/files"

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      [%MsnrFile{}, ...]

  """
  def list_files do
    Repo.all(MsnrFile)
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the MsnrFile does not exist.

  ## Examples

      iex> get_file!(123)
      %MsnrFile{}

      iex> get_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file!(id), do: Repo.get!(MsnrFile, id)

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{field: value})
      {:ok, %MsnrFile{}}

      iex> create_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file(attrs \\ %{}) do
    %MsnrFile{}
    |> MsnrFile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{field: new_value})
      {:ok, %MsnrFile{}}

      iex> update_file(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file(%MsnrFile{} = file, attrs) do
    file
    |> MsnrFile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_file(file)
      {:ok, %MsnrFile{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file(%MsnrFile{} = file) do
    Repo.delete(file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change_file(file)
      %Ecto.Changeset{data: %MsnrFile{}}

  """
  def change_file(%MsnrFile{} = file, attrs \\ %{}) do
    MsnrFile.changeset_student_file(file, attrs)
  end

  def store_file(src_file_path, file_name) do
    file_path = Path.join(@files_store, file_name)

    case File.copy(src_file_path, file_path) do
      {:ok, _ } -> {:ok, file_path}
      error -> error
    end
  end
end
