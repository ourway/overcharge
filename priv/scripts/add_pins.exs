import Ecto.Query


{:ok, files} = File.ls "priv/pins"
for f <- files do
    f |> IO.inspect
    {:ok, data} = File.read("priv/pins/#{f}")
    lines = data |> String.split("\r\n")
    for line <- lines do
        [serial, pin] = line |> String.split(" ") |> IO.inspect

        case (from p in Overcharge.Pin,
            where: p.serial == ^serial,
            where: p.code == ^pin,
            select: p.id) |> Overcharge.Repo.one do
                nil ->
                    {:ok, newpin} = Overcharge.Pin.changeset(
                         %Overcharge.Pin{},
                            %{
                                code: pin,
                                serial: serial,
                                amount: 1000
                            })
                    |> Overcharge.Repo.insert
                    newpin.id |> IO.inspect
                _ ->
                    :continue
            end


    end
end