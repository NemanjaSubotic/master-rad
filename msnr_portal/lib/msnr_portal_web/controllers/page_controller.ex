defmodule MsnrPortalWeb.PageController do
  use MsnrPortalWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
