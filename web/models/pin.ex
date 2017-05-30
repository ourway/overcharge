defmodule Overcharge.Pin do
  use Overcharge.Web, :model

  schema "pins" do
    field :uuid, :binary_id
    field :is_active, :boolean, default: false
    field :is_used, :boolean, default: false
    field :prefix, :integer
    field :amount, :integer
    field :serial, :string
    field :code, :string
    belongs_to :used_by, Overcharge.MSISDN
    belongs_to :invoice, Overcharge.Invoice

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :is_active, :is_used, :prefix, :serial, :code, :amount])
    |> validate_required([:serial, :code, :amount])
    |> unique_constraint(:code, [:code])
    |> unique_constraint(:serial, [:serial])
    |> cast_assoc(:used_by)
    |> cast_assoc(:invoice)
 
 
  end
end
