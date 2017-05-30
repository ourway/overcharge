defmodule Overcharge.Repo.Migrations.AddSuccessCallbackActionToInvoices do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :success_callback_action, :string, size: 64, null: false
      add :status, :string, size: 32, default: "pending",  null: false
    end

    create index(:invoices, [:status])

  end
end
