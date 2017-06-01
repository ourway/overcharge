defmodule Overcharge.Repo.Migrations.AddRateQuantityToInvoice do
  use Ecto.Migration



  def change do
    alter table(:invoices) do
      add :product, :string, size: 128, null: false
      add :quantity, :integer, default: 1, null: false
      add :rate, :integer, null: false
    end


  end


end
