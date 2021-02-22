defmodule MsnrApiWeb.Notifier do
  use Bamboo.Phoenix, view: MsnrApiWeb.EmailView
  alias MsnrApi.Mailer
  alias MsnrApi.Accounts.User

  @from "test@email.com"
  @base_url "http://localhost:8080/setPassword/"

  defp deliver_request_confirmation(%User{} = user) do
    new_email()
    |> from(@from)
    |> to(user.email)
    |> subject("Prihvacena prijava")
    |> assign(:user, user)
    |> assign(:url, @base_url <> user.password_url_path)
    |> render("request_confirmation.html")
    |> Mailer.deliver_now()
  end

  def sent_confirmation(user) do
    try do
      email = deliver_request_confirmation(user)
      {:ok, email}
    rescue
      _err ->
        # TO DO : log error
        {:error, :email_not_delivered}
    end
  end


end
