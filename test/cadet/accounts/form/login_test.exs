defmodule Cadet.Accounts.LoginTest do
  alias Cadet.Accounts.Form.Login

  use Cadet.ChangesetCase, entity: Login

  describe "Changesets" do
    test "valid changeset" do
      assert_changeset(%{ivle_token: "T0K3N"}, :valid)
    end

    test "invalid changeset" do
      assert_changeset(%{ivle_token: ""}, :invalid)
      assert_changeset(%{}, :invalid)
    end
  end
end
