defmodule Overcharge.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()")
      add :body, :text, null: false
      add :is_published, :boolean, default: false, null: false
      add :image_path, :string, size: 128
      add :links, :string, size: 512
      add :title, :string, size: 256, null: false
      add :tags, :string, size: 128
      add :stars, :integer, default: 0
      timestamps()
    end

      create index(:posts, [:title])
      create index(:posts, [:tags])

  end
end
