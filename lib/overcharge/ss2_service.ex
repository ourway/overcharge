defmodule Overcharge.SS2 do

	@base_url  "https://ss2.ir/api/save"



	def get(url) do
	    case Cachex.get!(:overcharge_cache, "ss2_cache_" <> url) do
	      nil -> 
			payload = %{link: url}
			{:ok,  %HTTPoison.Response{body: body}} = HTTPoison.post(@base_url, Poison.encode!(payload), 
					[{"Content-Type", "application/json"}], [ssl: [{:versions, [:'tlsv1.2']}] ])

	 		%{"shortlink" => short_link} = Poison.decode!(body)
		    Cachex.set(:overcharge_cache,  "ss2_cache_" <> url, short_link, [ ttl: :timer.seconds(24*3600*7), limit: 1000])
		    {:ok, short_link}
	      data ->
	        {:ok, data}
	    end

	end

	def get!(url) do
 		{:ok, short_link} = url |> get
 		short_link
	end

end