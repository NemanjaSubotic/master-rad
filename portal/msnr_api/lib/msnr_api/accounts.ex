defmodule MsnrApi.Accounts do

  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  alias Ecto.Multi

  alias MsnrApi.Accounts.Registration
  alias MsnrApi.Accounts.User
  alias MsnrApi.Accounts.Password
  alias MsnrApi.Accounts.Role
  alias MsnrApi.Students.Student
  alias MsnrApi.Semesters.Semester

  def authenticate(email, password) do
    user_info = get_user_info [email: email]

    with %{hashed_password: hash} <- user_info.user,
        true <- Password.verify_with_hash(password, hash) do
          {:ok, user_info}
    else
      _ -> {:error, :unauthorized}
    end
  end

  defp get_user_info(where_clause) do
    student_info = from st in Student,
      inner_join: sem in Semester, on: sem.is_active and sem.id == st.semester_id,
      select: st

    Repo.one  from u in User,
      inner_join: r in Role, on: u.role_id == r.id,
      left_join: s in subquery(student_info), on: s.user_id == u.id,
      preload: [:role],
      where: ^where_clause,
      select: %{
        user: u,
        student_info: %{
          student_id: s.id,
          group_id: s.group_id,
          semester_id: s.semester_id}
      }
  end

  def verify_user_by_token(id, token) do
    case get_user_info [id: id, refresh_token: token] do
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
      |> Multi.run(:student, fn _repo, %{user: user} ->
          %Student{}
          |> Student.changeset(%{user_id: user.id, index_number: registration.index_number})
          |> Repo.insert
      end)
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
