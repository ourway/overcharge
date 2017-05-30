defmodule Overcharge.Repo.Migrations.AddRawAmountToInvoice do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :raw_amount, :integer, null: false
      add :tax,:float, null: false, default: 0.09
    end


  end


end
