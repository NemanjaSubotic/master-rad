defmodule MsnrApiWeb.TaskControllerTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.Tasks
  alias MsnrApi.Tasks.Task

  @create_attrs %{
    ends: ~N[2010-04-17 14:00:00],
    points: 42,
    starts: ~N[2010-04-17 14:00:00]
  }
  @update_attrs %{
    ends: ~N[2011-05-18 15:01:01],
    points: 43,
    starts: ~N[2011-05-18 15:01:01]
  }
  @invalid_attrs %{ends: nil, points: nil, starts: nil}

  def fixture(:task) do
    {:ok, task} = Tasks.create_task(@create_attrs)
    task
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tasks", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task" do
    test "renders task when data is valid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.task_path(conn, :show, id))

      assert %{
               "id" => id,
               "ends" => "2010-04-17T14:00:00",
               "points" => 42,
               "starts" => "2010-04-17T14:00:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, task: %Task{id: id} = task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.task_path(conn, :show, id))

      assert %{
               "id" => id,
               "ends" => "2011-05-18T15:01:01",
               "points" => 43,
               "starts" => "2011-05-18T15:01:01"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, Routes.task_path(conn, :delete, task))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.task_path(conn, :show, task))
      end
    end
  end

  defp create_task(_) do
    task = fixture(:task)
    %{task: task}
  end
end
