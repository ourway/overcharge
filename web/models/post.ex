defmodule Overcharge.Post do
  use Overcharge.Web, :model

  schema "posts" do
    field :uuid, :binary_id
    field :body, :string
    field :is_published, :boolean, default: false
    field :image_path, :string
    field :links, :string
    field :title, :string
    field :tags, :string
    field :stars, :integer, default: 0

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:uuid, :body, :is_published, :image_path, :links, :title, :tags, :stars])
    |> validate_required([:body, :title])
  end
end
