defmodule Overcharge.Repo.Migrations.AddClientToPin do
  use Ecto.Migration

  def change do
    alter table(:pins) do
      add :client, :string, size: 64
    end
  end
end
