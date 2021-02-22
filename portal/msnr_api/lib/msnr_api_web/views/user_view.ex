defmodule MsnrApiWeb.UserView do
  use MsnrApiWeb, :view

  def render("user_id.json", %{user: user}) do
    %{id: user.id}
  end

end
