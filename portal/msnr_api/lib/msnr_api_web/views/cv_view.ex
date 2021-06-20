defmodule MsnrApiWeb.CVView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.CVView

  def render("index.json", %{cv: cv}) do
    %{data: render_many(cv, CVView, "cv.json")}
  end

  def render("show.json", %{cv: cv}) do
    %{data: render_one(cv, CVView, "cv.json")}
  end

  def render("cv.json", %{cv: cv}) do
    %{id: cv.id,
      points: cv.points}
  end
end
