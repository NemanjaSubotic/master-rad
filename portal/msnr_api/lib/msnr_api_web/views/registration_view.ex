defmodule MsnrApiWeb.RegistrationView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.RegistrationView

  def render("index.json", %{registrations: registrations}) do
    %{data: render_many(registrations, RegistrationView, "registration.json")}
  end

  def render("show.json", %{registration: registration}) do
    %{data: render_one(registration, RegistrationView, "registration.json")}
  end

  def render("registration.json", %{registration: registration}) do
    %{id: registration.id,
      email: registration.email,
      first_name: registration.first_name,
      last_name: registration.last_name,
      index_number: registration.index_number,
      status: registration.status}
  end
end
