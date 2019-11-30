defmodule Overcharge.PostTest do
  use Overcharge.ModelCase

  alias Overcharge.Post

  @valid_attrs %{body: "some content", image_path: "some content", is_published: true, links: "some content", stars: 42, tags: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end
end
