defmodule Overcharge.PageControllerTest do
  use Overcharge.ConnCase

  test "GET /api/ping", %{conn: conn} do
    conn = get conn, "/api/ping"
    assert json_response(conn, 200) == %{"message" => "pong"}
  end
end
