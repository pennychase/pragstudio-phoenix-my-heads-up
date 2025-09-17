defmodule MyHeadsUp.ResponsesTest do
  use MyHeadsUp.DataCase

  alias MyHeadsUp.Responses

  describe "responses" do
    alias MyHeadsUp.Responses.Response

    import MyHeadsUp.AccountsFixtures, only: [user_scope_fixture: 0]
    import MyHeadsUp.ResponsesFixtures

    @invalid_attrs %{status: nil, note: nil}

    test "list_responses/1 returns all scoped responses" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      response = response_fixture(scope)
      other_response = response_fixture(other_scope)
      assert Responses.list_responses(scope) == [response]
      assert Responses.list_responses(other_scope) == [other_response]
    end

    test "get_response!/2 returns the response with given id" do
      scope = user_scope_fixture()
      response = response_fixture(scope)
      other_scope = user_scope_fixture()
      assert Responses.get_response!(scope, response.id) == response
      assert_raise Ecto.NoResultsError, fn -> Responses.get_response!(other_scope, response.id) end
    end

    test "create_response/2 with valid data creates a response" do
      valid_attrs = %{status: :enroute, note: "some note"}
      scope = user_scope_fixture()

      assert {:ok, %Response{} = response} = Responses.create_response(scope, valid_attrs)
      assert response.status == :enroute
      assert response.note == "some note"
      assert response.user_id == scope.user.id
    end

    test "create_response/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Responses.create_response(scope, @invalid_attrs)
    end

    test "update_response/3 with valid data updates the response" do
      scope = user_scope_fixture()
      response = response_fixture(scope)
      update_attrs = %{status: :arrived, note: "some updated note"}

      assert {:ok, %Response{} = response} = Responses.update_response(scope, response, update_attrs)
      assert response.status == :arrived
      assert response.note == "some updated note"
    end

    test "update_response/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      response = response_fixture(scope)

      assert_raise MatchError, fn ->
        Responses.update_response(other_scope, response, %{})
      end
    end

    test "update_response/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      response = response_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Responses.update_response(scope, response, @invalid_attrs)
      assert response == Responses.get_response!(scope, response.id)
    end

    test "delete_response/2 deletes the response" do
      scope = user_scope_fixture()
      response = response_fixture(scope)
      assert {:ok, %Response{}} = Responses.delete_response(scope, response)
      assert_raise Ecto.NoResultsError, fn -> Responses.get_response!(scope, response.id) end
    end

    test "delete_response/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      response = response_fixture(scope)
      assert_raise MatchError, fn -> Responses.delete_response(other_scope, response) end
    end

    test "change_response/2 returns a response changeset" do
      scope = user_scope_fixture()
      response = response_fixture(scope)
      assert %Ecto.Changeset{} = Responses.change_response(scope, response)
    end
  end
end
