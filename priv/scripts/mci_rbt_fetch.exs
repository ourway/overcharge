
results = for i <- 0..4170 do
    url = "https://rbt.mci.ir/AJAX/latestTones.jsp?pgs=#{i}"
    IO.puts("getting page #{i}")
    {:ok, resp} = HTTPoison.get(url)
    html = resp.body
    rows = Floki.find(html, "tr") |> Enum.slice(1,10)

    rows |> Enum.map(fn({_,_, row}) ->
        row |> Enum.map(fn({_,_,[k]}) ->
            k
        end)
    end) |> Enum.map(fn(d) -> 
        [code, name, artist, duration, price] = d |> Enum.slice(0,5)
        %{name: name, code: code, artist: artist, duration: duration, price: price, wave: "https://rbt.mci.ir/wave/#{code}.wav"}
    end)
end

#{:ok, table} = :dets.open_file(:rbt_storage, [type: :set])
#:dets.insert_new(table, results)
#select_all = :ets.fun2ms(&(&1))
#File.write("priv/rbtstore/mci/data.json", Poison.encode!(results), [:binary])















