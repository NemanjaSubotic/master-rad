defmodule MsnrApi.Accounts do

  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  alias Ecto.Multi

  alias MsnrApi.Accounts.Registration
  alias MsnrApi.Accounts.User
  alias MsnrApi.Accounts.Password
  alias MsnrApi.Accounts.Role

  def authenticate(email, password) do
    user = Repo.get_by(User, email: email) |> Repo.preload(:role)
    IO.inspect(user)
    with %{hashed_password: hash} <- user,
        true <- Password.verify_with_hash(password, hash) do
          {:ok, user}
    else
      _ -> {:error, :unauthorized}
    end
  end

  def verify_user_by_token(id, token) do
    case Repo.get_by(User, [id: id, refresh_token: token]) |> Repo.preload(:role) do
      nil  -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  def verify_user_by_email(id, email) do
    case Repo.get_by(User, [id: id, email: email]) do
      nil  -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  def get_user_by_url!(url), do: Repo.get_by!(User, [password_url_path: url])

  def get_user!(id), do: Repo.get(User, id)

  def set_password(user, password) do
    user
    |> User.changeset_password(%{password: password})
    |> Repo.update
  end
  @doc """
  Returns the list of registrations.

  ## Examples

      iex> list_registrations()
      [%Registration{}, ...]

  """
  def list_registrations do
    Repo.all(Registration)
  end

  @doc """
  Gets a single registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration!(123)
      %Registration{}

      iex> get_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registration!(id), do: Repo.get!(Registration, id)

  # def get_registration(id) do
  #   case Repo.get(Registration, id) do
  #     nil -> {:error, :not_found}
  #     registration -> {:ok, registration}
  #   end
  # end

  def get_role!(name), do: Repo.get_by!(Role, [name: name])

  @doc """
  Creates a registration.

  ## Examples

      iex> create_registration(%{field: value})
      {:ok, %Registration{}}

      iex> create_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration(attrs \\ %{}) do
    %Registration{}
    |> Registration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a registration.

  ## Examples

      iex> update_registration(registration, %{field: new_value})
      {:ok, %Registration{}}

      iex> update_registration(registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration(%Registration{} = registration, attrs) do
    registration
    |> Registration.changeset_status(attrs)
    |> Repo.update()
  end

  def accept_registration(%Registration{} = registration) do
      student_role = get_role!(Role.student)
      reg_changeset = Registration.changeset_status(registration, %{status: Registration.Status.accepted})
      user_changeset =
        %User{}
        |> User.changeset(%{email: registration.email, first_name: registration.first_name, last_name: registration.last_name})
        |> User.changeset_role(student_role)

      Multi.new()
      |> Multi.update(:registration, reg_changeset)
      |> Multi.insert(:user, user_changeset)
  end

  @doc """
  Deletes a registration.

  ## Examples

      iex> delete_registration(registration)
      {:ok, %Registration{}}

      iex> delete_registration(registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registration(%Registration{} = registration) do
    Repo.delete(registration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration changes.

  ## Examples

      iex> change_registration(registration)
      %Ecto.Changeset{data: %Registration{}}

  """
  def change_registration(%Registration{} = registration, attrs \\ %{}) do
    Registration.changeset(registration, attrs)
  end
end
