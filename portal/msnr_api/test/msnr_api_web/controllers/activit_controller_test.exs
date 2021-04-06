defmodule MsnrApiWeb.ActivitControllerTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.Activities
  alias MsnrApi.Activities.Activit

  @create_attrs %{
    ends_sec: 42,
    starts_sec: 42
  }
  @update_attrs %{
    ends_sec: 43,
    starts_sec: 43
  }
  @invalid_attrs %{ends_sec: nil, starts_sec: nil}

  def fixture(:activit) do
    {:ok, activit} = Activities.create_activit(@create_attrs)
    activit
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all activities", %{conn: conn} do
      conn = get(conn, Routes.activit_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create activit" do
    test "renders activit when data is valid", %{conn: conn} do
      conn = post(conn, Routes.activit_path(conn, :create), activit: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.activit_path(conn, :show, id))

      assert %{
               "id" => id,
               "ends_sec" => 42,
               "starts_sec" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.activit_path(conn, :create), activit: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update activit" do
    setup [:create_activit]

    test "renders activit when data is valid", %{conn: conn, activit: %Activity{id: id} = activit} do
      conn = put(conn, Routes.activit_path(conn, :update, activit), activit: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.activit_path(conn, :show, id))

      assert %{
               "id" => id,
               "ends_sec" => 43,
               "starts_sec" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, activit: activit} do
      conn = put(conn, Routes.activit_path(conn, :update, activit), activit: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete activit" do
    setup [:create_activit]

    test "deletes chosen activit", %{conn: conn, activit: activit} do
      conn = delete(conn, Routes.activit_path(conn, :delete, activit))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.activit_path(conn, :show, activit))
      end
    end
  end

  defp create_activit(_) do
    activit = fixture(:activit)
    %{activit: activit}
  end
end
