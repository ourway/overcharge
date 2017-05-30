defmodule Overcharge.Repo.Migrations.AddMissingUserIdToInvoices do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :user_id, references(:msisdns, on_delete: :nothing)
    end

    create index(:invoices, [:user_id])

  end
end
