defmodule MsnrApiWeb.RegistrationControllerTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.Accounts
  alias MsnrApi.Accounts.Registration

  @create_attrs %{
    email: "some email",
    first_name: "some first_name",
    index_number: "some index_number",
    last_name: "some last_name",
    status: "some status",
    url_path: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    email: "some updated email",
    first_name: "some updated first_name",
    index_number: "some updated index_number",
    last_name: "some updated last_name",
    status: "some updated status",
    url_path: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{email: nil, first_name: nil, index_number: nil, last_name: nil, status: nil, url_path: nil}

  def fixture(:registration) do
    {:ok, registration} = Accounts.create_registration(@create_attrs)
    registration
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all registrations", %{conn: conn} do
      conn = get(conn, Routes.registration_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create registration" do
    test "renders registration when data is valid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), registration: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.registration_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some email",
               "first_name" => "some first_name",
               "index_number" => "some index_number",
               "last_name" => "some last_name",
               "status" => "some status",
               "url_path" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), registration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update registration" do
    setup [:create_registration]

    test "renders registration when data is valid", %{conn: conn, registration: %Registration{id: id} = registration} do
      conn = put(conn, Routes.registration_path(conn, :update, registration), registration: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.registration_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some updated email",
               "first_name" => "some updated first_name",
               "index_number" => "some updated index_number",
               "last_name" => "some updated last_name",
               "status" => "some updated status",
               "url_path" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, registration: registration} do
      conn = put(conn, Routes.registration_path(conn, :update, registration), registration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete registration" do
    setup [:create_registration]

    test "deletes chosen registration", %{conn: conn, registration: registration} do
      conn = delete(conn, Routes.registration_path(conn, :delete, registration))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.registration_path(conn, :show, registration))
      end
    end
  end

  defp create_registration(_) do
    registration = fixture(:registration)
    %{registration: registration}
  end
end
