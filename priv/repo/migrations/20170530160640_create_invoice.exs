defmodule Overcharge.Repo.Migrations.CreateInvoice do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()")
      add :is_checked_out, :boolean, default: false, null: false
      add :amount, :integer, null: false
      add :description, :string, size: 256
      add :client, :string, size: 64
      add :paylink, :string, size: 256
      add :refid, :string, null: false, default: fragment("substring(md5(random()::text) from 0 for 12)")
      add :user, references(:msisdns, on_delete: :nothing)

      timestamps()
    end
    create index(:invoices, [:user])
    create unique_index(:invoices, [:refid])

  end
end
