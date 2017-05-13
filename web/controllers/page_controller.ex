defmodule Overcharge.PageController do
  use Overcharge.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
