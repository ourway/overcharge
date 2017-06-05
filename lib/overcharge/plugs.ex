defmodule Overcharge.CORS do
	@behaviour Plug
	use Plug.Builder


    def init(opts) do
		opts
	end

	def call(conn, opts) do
        c = Plug.Conn.fetch_query_params(conn, opts)
        origin = c.query_params |> Map.get("__amp_source_origin")
        host =  Overcharge.Router.Helpers.url(conn)
        #origin = conn |> Plug.Conn.get_req_header("origin") |> List.first
        conn
            |> Plug.Conn.put_resp_header("amp-same-origin", "true")
            |> Plug.Conn.put_resp_header("access-control-allow-credentials", "true")
            |> Plug.Conn.put_resp_header("amp-access-control-allow-source-origin", host)
            |> Plug.Conn.put_resp_header("access-control-allow-origin", origin || host)
            |> Plug.Conn.put_resp_header("access-control-expose-headers", 
                "amp-access-control-allow-source-origin, access-control-allow-origin, amp-redirect-to")
    end

end


defmodule Overcharge.Admin do
	@behaviour Plug
	use Plug.Builder


    def init(opts) do
		opts
	end

	def call(conn, opts) do
        c = Plug.Conn.fetch_query_params(conn, opts)
        pass = c.query_params |> Map.get("_ua_password")
        if pass == "6401ffa3-beae-46f3-94a5-a374b2b50738" do
            conn
        else
            conn 
                |> Plug.Conn.send_resp(401, "401 - Not Authenticated")
                |> halt
        end
    end

end
