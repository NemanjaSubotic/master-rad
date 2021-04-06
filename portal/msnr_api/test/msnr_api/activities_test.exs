defmodule MsnrApi.ActivitiesTest do
  use MsnrApi.DataCase

  alias MsnrApi.Activities

  describe "activities" do
    alias MsnrApi.Activities.Activit

    @valid_attrs %{ends_sec: 42, starts_sec: 42}
    @update_attrs %{ends_sec: 43, starts_sec: 43}
    @invalid_attrs %{ends_sec: nil, starts_sec: nil}

    def activit_fixture(attrs \\ %{}) do
      {:ok, activit} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Activities.create_activit()

      activit
    end

    test "list_activities/0 returns all activities" do
      activit = activit_fixture()
      assert Activities.list_activities() == [activit]
    end

    test "get_activit!/1 returns the activit with given id" do
      activit = activit_fixture()
      assert Activities.get_activit!(activit.id) == activit
    end

    test "create_activit/1 with valid data creates a activit" do
      assert {:ok, %Activity{} = activit} = Activities.create_activit(@valid_attrs)
      assert activit.ends_sec == 42
      assert activit.starts_sec == 42
    end

    test "create_activit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_activit(@invalid_attrs)
    end

    test "update_activit/2 with valid data updates the activit" do
      activit = activit_fixture()
      assert {:ok, %Activity{} = activit} = Activities.update_activit(activit, @update_attrs)
      assert activit.ends_sec == 43
      assert activit.starts_sec == 43
    end

    test "update_activit/2 with invalid data returns error changeset" do
      activit = activit_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_activit(activit, @invalid_attrs)
      assert activit == Activities.get_activit!(activit.id)
    end

    test "delete_activit/1 deletes the activit" do
      activit = activit_fixture()
      assert {:ok, %Activity{}} = Activities.delete_activit(activit)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_activit!(activit.id) end
    end

    test "change_activit/1 returns a activit changeset" do
      activit = activit_fixture()
      assert %Ecto.Changeset{} = Activities.change_activit(activit)
    end
  end
end
