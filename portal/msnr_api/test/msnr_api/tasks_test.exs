defmodule MsnrApi.TasksTest do
  use MsnrApi.DataCase

  alias MsnrApi.Tasks

  describe "tasks" do
    alias MsnrApi.Tasks.Task

    @valid_attrs %{ends: ~N[2010-04-17 14:00:00], points: 42, starts: ~N[2010-04-17 14:00:00]}
    @update_attrs %{ends: ~N[2011-05-18 15:01:01], points: 43, starts: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{ends: nil, points: nil, starts: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tasks.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Tasks.create_task(@valid_attrs)
      assert task.ends == ~N[2010-04-17 14:00:00]
      assert task.points == 42
      assert task.starts == ~N[2010-04-17 14:00:00]
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Tasks.update_task(task, @update_attrs)
      assert task.ends == ~N[2011-05-18 15:01:01]
      assert task.points == 43
      assert task.starts == ~N[2011-05-18 15:01:01]
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
