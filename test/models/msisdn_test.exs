defmodule Overcharge.MSISDNTest do
  use Overcharge.ModelCase

  alias Overcharge.MSISDN

  @valid_attrs %{city: "some content", country: "some content", is_active: true, msisdn: "some content", state: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MSISDN.changeset(%MSISDN{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MSISDN.changeset(%MSISDN{}, @invalid_attrs)
    refute changeset.valid?
  end
end
