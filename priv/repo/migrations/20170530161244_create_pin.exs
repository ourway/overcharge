defmodule Overcharge.Repo.Migrations.CreatePin do
  use Ecto.Migration

  def change do
    create table(:pins) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()")
      add :is_active, :boolean, default: true, null: false
      add :is_used, :boolean, default: false, null: false
      add :prefix, :integer
      add :amount, :integer
      add :serial, :string, null: false
      add :code, :string, null: false
      add :used_by, references(:msisdns, on_delete: :nothing)
      add :invoice, references(:invoices, on_delete: :nothing)

      timestamps()
    end
    create index(:pins, [:used_by])
    create index(:pins, [:code, :is_used, :amount])
    create unique_index(:pins, [:serial])
    create unique_index(:pins, [:code])
  end
end
