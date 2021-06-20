defmodule MsnrApi.CVsTest do
  use MsnrApi.DataCase

  alias MsnrApi.CVs

  describe "cv" do
    alias MsnrApi.CVs.CV

    @valid_attrs %{points: 42}
    @update_attrs %{points: 43}
    @invalid_attrs %{points: nil}

    def cv_fixture(attrs \\ %{}) do
      {:ok, cv} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CVs.create_cv()

      cv
    end

    test "list_cv/0 returns all cv" do
      cv = cv_fixture()
      assert CVs.list_cv() == [cv]
    end

    test "get_cv!/1 returns the cv with given id" do
      cv = cv_fixture()
      assert CVs.get_cv!(cv.id) == cv
    end

    test "create_cv/1 with valid data creates a cv" do
      assert {:ok, %CV{} = cv} = CVs.create_cv(@valid_attrs)
      assert cv.points == 42
    end

    test "create_cv/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CVs.create_cv(@invalid_attrs)
    end

    test "update_cv/2 with valid data updates the cv" do
      cv = cv_fixture()
      assert {:ok, %CV{} = cv} = CVs.update_cv(cv, @update_attrs)
      assert cv.points == 43
    end

    test "update_cv/2 with invalid data returns error changeset" do
      cv = cv_fixture()
      assert {:error, %Ecto.Changeset{}} = CVs.update_cv(cv, @invalid_attrs)
      assert cv == CVs.get_cv!(cv.id)
    end

    test "delete_cv/1 deletes the cv" do
      cv = cv_fixture()
      assert {:ok, %CV{}} = CVs.delete_cv(cv)
      assert_raise Ecto.NoResultsError, fn -> CVs.get_cv!(cv.id) end
    end

    test "change_cv/1 returns a cv changeset" do
      cv = cv_fixture()
      assert %Ecto.Changeset{} = CVs.change_cv(cv)
    end
  end
end
