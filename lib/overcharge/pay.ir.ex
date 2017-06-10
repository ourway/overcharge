defmodule Overcharge.Pay do
    ## pay.ir
    @apikey "499dc0e6059efa42ee8af59149e1cb41"
    @baseurl "https://pay.ir/payment"

    @doc """
    Overcharge.Repo.get(Overcharge.Invoice, 100) |> Overcharge.Pay.request
    """
    def request(invoice) do
        {:ok, payload} = %{
            "api" =>            @apikey,
            "amount" =>         invoice.amount * 10,
            "redirect" =>       "https://www.chargell.com/deliver/#{invoice.uuid}",
            "factorNumber" =>   invoice.refid
        } |> Poison.encode

       {:ok,  %HTTPoison.Response{body: body}} = HTTPoison.post("#{@baseurl}/send", payload, 
					                    [{"Content-Type", "application/json"}], [])
       %{"status" => 1, "transId" => transactionid} = body |> Poison.decode!
       {:ok, ivs} = invoice |> Overcharge.Invoice.changeset(
            %{ transactionid: transactionid |> to_string }) |> Overcharge.Repo.update
       ivs
    end


    def verify(invoice) do
        {:ok, payload} = %{
            "api" =>            @apikey,
            "transId" =>        invoice.transactionid |> String.to_integer
        } |> Poison.encode
        {:ok,  %HTTPoison.Response{body: body}} = HTTPoison.post("#{@baseurl}/verify", payload, 
					 [{"Content-Type", "application/json"}], [])
        %{ "status" => status} = body |> Poison.decode!
        status
    end





end