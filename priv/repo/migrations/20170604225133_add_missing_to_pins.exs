defmodule Overcharge.Repo.Migrations.AddMissingToPins do
  use Ecto.Migration

  def change do
    alter table(:pins) do
      add :used_by_id, references(:msisdns, on_delete: :nothing)
      add :invoice_id, references(:invoices, on_delete: :nothing)
    end

    drop index(:pins, [:used_by])
    create index(:pins, [:used_by_id])
    create index(:pins, [:invoice_id])

  end
end
