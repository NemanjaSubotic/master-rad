defmodule MsnrApi.SemestersTest do
  use MsnrApi.DataCase

  alias MsnrApi.Semesters

  describe "semesters" do
    alias MsnrApi.Semesters.Semester

    @valid_attrs %{is_active: true, module: "some module", ordinal_number: 42, year: 42}
    @update_attrs %{is_active: false, module: "some updated module", ordinal_number: 43, year: 43}
    @invalid_attrs %{is_active: nil, module: nil, ordinal_number: nil, year: nil}

    def semester_fixture(attrs \\ %{}) do
      {:ok, semester} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Semesters.create_semester()

      semester
    end

    test "list_semesters/0 returns all semesters" do
      semester = semester_fixture()
      assert Semesters.list_semesters() == [semester]
    end

    test "get_semester!/1 returns the semester with given id" do
      semester = semester_fixture()
      assert Semesters.get_semester!(semester.id) == semester
    end

    test "create_semester/1 with valid data creates a semester" do
      assert {:ok, %Semester{} = semester} = Semesters.create_semester(@valid_attrs)
      assert semester.is_active == true
      assert semester.module == "some module"
      assert semester.ordinal_number == 42
      assert semester.year == 42
    end

    test "create_semester/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Semesters.create_semester(@invalid_attrs)
    end

    test "update_semester/2 with valid data updates the semester" do
      semester = semester_fixture()
      assert {:ok, %Semester{} = semester} = Semesters.update_semester(semester, @update_attrs)
      assert semester.is_active == false
      assert semester.module == "some updated module"
      assert semester.ordinal_number == 43
      assert semester.year == 43
    end

    test "update_semester/2 with invalid data returns error changeset" do
      semester = semester_fixture()
      assert {:error, %Ecto.Changeset{}} = Semesters.update_semester(semester, @invalid_attrs)
      assert semester == Semesters.get_semester!(semester.id)
    end

    test "delete_semester/1 deletes the semester" do
      semester = semester_fixture()
      assert {:ok, %Semester{}} = Semesters.delete_semester(semester)
      assert_raise Ecto.NoResultsError, fn -> Semesters.get_semester!(semester.id) end
    end

    test "change_semester/1 returns a semester changeset" do
      semester = semester_fixture()
      assert %Ecto.Changeset{} = Semesters.change_semester(semester)
    end
  end
end
