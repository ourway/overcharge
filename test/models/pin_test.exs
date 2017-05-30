defmodule Overcharge.PinTest do
  use Overcharge.ModelCase

  alias Overcharge.Pin

  @valid_attrs %{code: "some content", is_active: true, is_used: true, prefix: 42, serial: "some content", amount: 1000}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Pin.changeset(%Pin{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Pin.changeset(%Pin{}, @invalid_attrs)
    refute changeset.valid?
  end
end
