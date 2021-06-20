defmodule MsnrApiWeb.CVControllerTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.CVs
  alias MsnrApi.CVs.CV

  @create_attrs %{
    points: 42
  }
  @update_attrs %{
    points: 43
  }
  @invalid_attrs %{points: nil}

  def fixture(:cv) do
    {:ok, cv} = CVs.create_cv(@create_attrs)
    cv
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all cv", %{conn: conn} do
      conn = get(conn, Routes.cv_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create cv" do
    test "renders cv when data is valid", %{conn: conn} do
      conn = post(conn, Routes.cv_path(conn, :create), cv: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.cv_path(conn, :show, id))

      assert %{
               "id" => id,
               "points" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.cv_path(conn, :create), cv: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update cv" do
    setup [:create_cv]

    test "renders cv when data is valid", %{conn: conn, cv: %CV{id: id} = cv} do
      conn = put(conn, Routes.cv_path(conn, :update, cv), cv: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.cv_path(conn, :show, id))

      assert %{
               "id" => id,
               "points" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, cv: cv} do
      conn = put(conn, Routes.cv_path(conn, :update, cv), cv: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete cv" do
    setup [:create_cv]

    test "deletes chosen cv", %{conn: conn, cv: cv} do
      conn = delete(conn, Routes.cv_path(conn, :delete, cv))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.cv_path(conn, :show, cv))
      end
    end
  end

  defp create_cv(_) do
    cv = fixture(:cv)
    %{cv: cv}
  end
end
