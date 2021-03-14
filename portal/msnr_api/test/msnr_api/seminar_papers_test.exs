defmodule MsnrApi.SeminarPapersTest do
  use MsnrApi.DataCase

  alias MsnrApi.SeminarPapers

  describe "seminar_papers" do
    alias MsnrApi.SeminarPapers.SeminarPaper

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def seminar_paper_fixture(attrs \\ %{}) do
      {:ok, seminar_paper} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SeminarPapers.create_seminar_paper()

      seminar_paper
    end

    test "list_seminar_papers/0 returns all seminar_papers" do
      seminar_paper = seminar_paper_fixture()
      assert SeminarPapers.list_seminar_papers() == [seminar_paper]
    end

    test "get_seminar_paper!/1 returns the seminar_paper with given id" do
      seminar_paper = seminar_paper_fixture()
      assert SeminarPapers.get_seminar_paper!(seminar_paper.id) == seminar_paper
    end

    test "create_seminar_paper/1 with valid data creates a seminar_paper" do
      assert {:ok, %SeminarPaper{} = seminar_paper} = SeminarPapers.create_seminar_paper(@valid_attrs)
    end

    test "create_seminar_paper/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SeminarPapers.create_seminar_paper(@invalid_attrs)
    end

    test "update_seminar_paper/2 with valid data updates the seminar_paper" do
      seminar_paper = seminar_paper_fixture()
      assert {:ok, %SeminarPaper{} = seminar_paper} = SeminarPapers.update_seminar_paper(seminar_paper, @update_attrs)
    end

    test "update_seminar_paper/2 with invalid data returns error changeset" do
      seminar_paper = seminar_paper_fixture()
      assert {:error, %Ecto.Changeset{}} = SeminarPapers.update_seminar_paper(seminar_paper, @invalid_attrs)
      assert seminar_paper == SeminarPapers.get_seminar_paper!(seminar_paper.id)
    end

    test "delete_seminar_paper/1 deletes the seminar_paper" do
      seminar_paper = seminar_paper_fixture()
      assert {:ok, %SeminarPaper{}} = SeminarPapers.delete_seminar_paper(seminar_paper)
      assert_raise Ecto.NoResultsError, fn -> SeminarPapers.get_seminar_paper!(seminar_paper.id) end
    end

    test "change_seminar_paper/1 returns a seminar_paper changeset" do
      seminar_paper = seminar_paper_fixture()
      assert %Ecto.Changeset{} = SeminarPapers.change_seminar_paper(seminar_paper)
    end
  end
end
