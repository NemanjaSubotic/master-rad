defmodule MsnrApi.AccountsTest do
  use MsnrApi.DataCase

  alias MsnrApi.Accounts

  describe "registrations" do
    alias MsnrApi.Accounts.Registration

    @valid_attrs %{email: "some email", first_name: "some first_name", index_number: "some index_number", last_name: "some last_name", status: "some status", url_path: "7488a646-e31f-11e4-aace-600308960662"}
    @update_attrs %{email: "some updated email", first_name: "some updated first_name", index_number: "some updated index_number", last_name: "some updated last_name", status: "some updated status", url_path: "7488a646-e31f-11e4-aace-600308960668"}
    @invalid_attrs %{email: nil, first_name: nil, index_number: nil, last_name: nil, status: nil, url_path: nil}

    def registration_fixture(attrs \\ %{}) do
      {:ok, registration} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_registration()

      registration
    end

    test "list_registrations/0 returns all registrations" do
      registration = registration_fixture()
      assert Accounts.list_registrations() == [registration]
    end

    test "get_registration!/1 returns the registration with given id" do
      registration = registration_fixture()
      assert Accounts.get_registration!(registration.id) == registration
    end

    test "create_registration/1 with valid data creates a registration" do
      assert {:ok, %Registration{} = registration} = Accounts.create_registration(@valid_attrs)
      assert registration.email == "some email"
      assert registration.first_name == "some first_name"
      assert registration.index_number == "some index_number"
      assert registration.last_name == "some last_name"
      assert registration.status == "some status"
      assert registration.url_path == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_registration(@invalid_attrs)
    end

    test "update_registration/2 with valid data updates the registration" do
      registration = registration_fixture()
      assert {:ok, %Registration{} = registration} = Accounts.update_registration(registration, @update_attrs)
      assert registration.email == "some updated email"
      assert registration.first_name == "some updated first_name"
      assert registration.index_number == "some updated index_number"
      assert registration.last_name == "some updated last_name"
      assert registration.status == "some updated status"
      assert registration.url_path == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_registration/2 with invalid data returns error changeset" do
      registration = registration_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_registration(registration, @invalid_attrs)
      assert registration == Accounts.get_registration!(registration.id)
    end

    test "delete_registration/1 deletes the registration" do
      registration = registration_fixture()
      assert {:ok, %Registration{}} = Accounts.delete_registration(registration)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_registration!(registration.id) end
    end

    test "change_registration/1 returns a registration changeset" do
      registration = registration_fixture()
      assert %Ecto.Changeset{} = Accounts.change_registration(registration)
    end
  end
end
