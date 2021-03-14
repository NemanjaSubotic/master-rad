defmodule MsnrApiWeb.SeminarPaperControllerTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.SeminarPapers
  alias MsnrApi.SeminarPapers.SeminarPaper

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:seminar_paper) do
    {:ok, seminar_paper} = SeminarPapers.create_seminar_paper(@create_attrs)
    seminar_paper
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all seminar_papers", %{conn: conn} do
      conn = get(conn, Routes.seminar_paper_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create seminar_paper" do
    test "renders seminar_paper when data is valid", %{conn: conn} do
      conn = post(conn, Routes.seminar_paper_path(conn, :create), seminar_paper: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.seminar_paper_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.seminar_paper_path(conn, :create), seminar_paper: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update seminar_paper" do
    setup [:create_seminar_paper]

    test "renders seminar_paper when data is valid", %{conn: conn, seminar_paper: %SeminarPaper{id: id} = seminar_paper} do
      conn = put(conn, Routes.seminar_paper_path(conn, :update, seminar_paper), seminar_paper: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.seminar_paper_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, seminar_paper: seminar_paper} do
      conn = put(conn, Routes.seminar_paper_path(conn, :update, seminar_paper), seminar_paper: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete seminar_paper" do
    setup [:create_seminar_paper]

    test "deletes chosen seminar_paper", %{conn: conn, seminar_paper: seminar_paper} do
      conn = delete(conn, Routes.seminar_paper_path(conn, :delete, seminar_paper))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.seminar_paper_path(conn, :show, seminar_paper))
      end
    end
  end

  defp create_seminar_paper(_) do
    seminar_paper = fixture(:seminar_paper)
    %{seminar_paper: seminar_paper}
  end
end
