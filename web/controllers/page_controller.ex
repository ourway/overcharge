defmodule Overcharge.PageController do
  use Overcharge.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def mci(conn, _params) do
    render conn, "mci.html"
  end

  def irancell(conn, _params) do
    render conn, "irancell.html"
  end

  def rightel(conn, _params) do
    render conn, "rightel.html"
  end

  def taliya(conn, _params) do
    render conn, "taliya.html"
  end






end
