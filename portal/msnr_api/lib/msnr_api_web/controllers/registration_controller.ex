defmodule MsnrApiWeb.RegistrationController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Accounts
  alias MsnrApi.Accounts.Registration

  alias MsnrApiWeb.Notifier

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, _params) do
    registrations = Accounts.list_registrations()
    render(conn, "index.json", registrations: registrations)
  end

  def create(conn, %{"registration" => registration_params}) do
    with {:ok, %Registration{} = registration} <- Accounts.create_registration(registration_params) do
      conn
      |> put_status(:created)
      |> render("show.json", registration: registration)
    end
  end

  # def show(conn, %{"id" => uuid}) do
  #   with {:ok, registration} <- Accounts.get_accepted_registration(uuid) do
  #     render(conn, "show.json", registration: registration)
  #   end
  # end

  def update(conn, %{"id" => id, "registration" => %{"status" => status}}) do
    registration = Accounts.get_registration!(id)

    if status == Registration.Status.accepted do
      accept_registration(conn, registration)
    else
      with {:ok, %Registration{} = registration} <- Accounts.update_registration(registration, %{status: status}) do
        render(conn, "show.json", registration: registration)
      end
    end
  end

  defp accept_registration(conn, registration) do
    multi_struct =
      Accounts.accept_registration(registration)
      |> Ecto.Multi.run( :email, fn _repo, %{user: user} -> Notifier.sent_confirmation(user) end)

    case MsnrApi.Repo.transaction(multi_struct) do
      {:ok, %{registration: registration} } ->
        render(conn, "show.json", registration: registration)

      {:error, :registration, reg_changeset, _changes_so_far} ->
        {:error, reg_changeset}

      {:error, :user, user_changeset, _changes_so_far} ->
        {:error, user_changeset}

      {:error, :email, _error, _changes_so_far} ->

        {:error, %{message: "Greska prilikom slanja mail-a"}}
      end
  end

end
