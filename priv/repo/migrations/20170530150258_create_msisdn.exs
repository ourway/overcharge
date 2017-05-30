defmodule Overcharge.Repo.Migrations.CreateMSISDN do
  use Ecto.Migration

  def change do
    create table(:msisdns) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()")
      add :is_active, :boolean, default: true, null: false
      add :msisdn, :string, size: 16, null: false
      add :country, :string
      add :state, :string
      add :city, :string

      timestamps()
    end

    create unique_index(:msisdns, [:msisdn])

  end
end
