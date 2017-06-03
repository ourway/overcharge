defmodule Overcharge.Repo.Migrations.AddTransactionidToInvoice do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :transactionid, :string, size: 64
    end

  end
end
