defmodule Overcharge.Invoice do
  use Overcharge.Web, :model

  schema "invoices" do
    field :uuid, :binary_id
    field :is_checked_out, :boolean, default: false
    field :amount, :integer
    field :rate, :integer
    field :raw_amount, :integer
    field :quantity, :integer, default: 1
    field :tax, :float, default: 0.09
    field :description, :string
    field :product, :string
    field :transactionid, :string
    field :success_callback_action, :string
    field :status, :string
    field :client, :string
    field :paylink, :string
    field :refid, :string
    belongs_to :user, Overcharge.MSISDN

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:transactionid, :product, :quantity, :rate, :tax, :raw_amount, :id, :is_checked_out, :amount, :description, :client, :paylink, :refid, :success_callback_action, :status])
    |> validate_required([:product, :rate, :amount, :raw_amount, :description, :success_callback_action])
    |> unique_constraint(:refid, [:refid])
    |> cast_assoc(:user)
  end
end
