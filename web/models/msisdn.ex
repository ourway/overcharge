defmodule Overcharge.MSISDN do
  use Overcharge.Web, :model

  schema "msisdns" do
    field :uuid, :binary_id
    field :is_active, :boolean, default: false
    field :msisdn, :string
    field :country, :string
    field :state, :string
    field :city, :string
    has_many :invoices, Overcharge.Invoice

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :is_active, :msisdn, :country, :state, :city])
    |> validate_required([:msisdn])
    |> unique_constraint(:msisdn, [:msisdn])
    |> cast_assoc(:invoices)
  end
end
