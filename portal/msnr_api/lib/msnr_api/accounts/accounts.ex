defmodule MsnrApi.Accounts do
  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  alias MsnrApi.Accounts.User
  alias MsnrApi.Accounts.Password

  def authenticate(email, password) do
    user = Repo.get_by(User, email: email)

    with %{hashed_password: hash} <- user,
          true <- Password.verify_with_hash(password, hash) do
      {:ok, user}
    else
      _ -> {:error}
    end
  end
end
