defmodule Overcharge.Repo.Migrations.AddMsisdnToPin do
  use Ecto.Migration

  def change do
    alter table(:pins) do
      add :msisdn, :string, size: 16
    end
  end
end
