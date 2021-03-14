defmodule MsnrApiWeb.FileView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.FileView

  def render("index.json", %{files: files}) do
    %{data: render_many(files, FileView, "file.json")}
  end

  def render("show.json", %{file: file}) do
    %{data: render_one(file, FileView, "file.json")}
  end

  def render("file.json", %{file: file}) do
    %{id: file.id,
      file_path: file.file_path}
  end
end
