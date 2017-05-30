defmodule Overcharge.InvoiceTest do
  use Overcharge.ModelCase

  alias Overcharge.Invoice

  @valid_attrs %{status: "pending", success_callback_action: "mci_topup_1000_989120228207", amount: 42, raw_amount: 40, tax: 0.09, client: "some content", description: "some content", is_checked_out: true, paylink: "some content", refid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Invoice.changeset(%Invoice{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Invoice.changeset(%Invoice{}, @invalid_attrs)
    refute changeset.valid?
  end
end
