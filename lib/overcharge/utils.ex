defmodule Overcharge.Utils do

    import Ecto.Query

    def get_random_string(len \\ 16) do
        Ecto.UUID.generate |> binary_part(16,len)
    end

    def validate_msisdn(num) do
        %{"nn" => postfix} = Regex.named_captures(~r/(^09|^989|^9)(?<nn>\d*)/, num)
        "989#{postfix}"
    end

    def get_client(msisdn) do
        case (from m in Overcharge.MSISDN, 
                          where: m.msisdn == ^msisdn, 
                          select: m)
                      |> Overcharge.Repo.one do
                nil ->
                  {:ok, c} = Overcharge.MSISDN.changeset(
                                  %Overcharge.MSISDN{},
                                  %{ msisdn: msisdn })
                              |> Overcharge.Repo.insert_or_update
                      c
                c ->
                  c
        end
    end


    def create_invoice(action, amount, client, product) do 
      amount = amount
      off = 0.0  ##indirim :)
      rate = amount*(1-off) |> Float.ceil |> round
      {:ok, invoice} = Overcharge.Invoice.changeset(
                %Overcharge.Invoice{},
                %{
                    refid: get_random_string(14),
                    description: action,
                    product: product,
                    rate: rate,
                    success_callback_action: action,
                    raw_amount: rate,
                    amount: (rate + rate*0.09) |> round
                })
               |> Ecto.Changeset.change
               |> Ecto.Changeset.put_assoc(:user, client)
        |> Overcharge.Repo.insert

        invoice
    end



    def get_invoice(refid) do
        (from i in Overcharge.Invoice, 
                          where: i.refid == ^refid, 
                          select: i)
        |> Overcharge.Repo.one
    end

    def get_invoice_uuid(uuid) do
        (from i in Overcharge.Invoice, 
                          where: i.uuid == ^uuid, 
                          select: i)
        |> Overcharge.Repo.one
    end


    def date_to_tehran_timezone(date) do
        date |> Calendar.DateTime.shift_zone!("Asia/Tehran") 
    end

    def date_to_persian(date) do
        base = date 
                    |> DateTime.from_naive!("Etc/UTC")
                    |> date_to_tehran_timezone 
                    |> Jalaali.to_jalaali 
                    |> DateTime.to_string 
                    |> String.split(" ")
                    |> Enum.slice(0,2)
        p2 = base |> List.last |> String.split(":") |> Enum.slice(0,2) |> Enum.join(":")
        p1 = base |> List.first

        "#{p1} #{p2}"
    end


    def get_mci_rbt_data(page) do

        case Cachex.get(:overcharge_cache, "mci_rbt_cache_page_#{page}") do
            {:missing, nil} ->
                url = "https://rbt.mci.ir/AJAX/latestTones.jsp?pgs=#{page}"
                {:ok, resp} = HTTPoison.get(url)
                html = resp.body
                rows = Floki.find(html, "tr") |> Enum.slice(1,10)

                result = rows |> Enum.map(fn({_,_, row}) ->
                    row |> Enum.map(fn({_,_,[k]}) ->
                        k
                end)
                    end) |> Enum.map(fn(d) -> 
                        [code, name, artist, duration, price] = d |> Enum.slice(0,5)
                        %{name: name, code: code, artist: artist, duration: duration, price: price, wave: "https://rbt.mci.ir/wave/#{code}.wav"}
                end)
                {:ok, true} = Cachex.set(:overcharge_cache, "mci_rbt_cache_page_#{page}", result)
                result
            {:ok, data} ->
                data
        end

    end

    def post_xml(url, data) do
        {:ok, resp} = HTTPoison.post(url, data, ["Content-Type": "text/xml"])
        resp
    end


    def set_transactionid(invoice, transactionid) do
        Overcharge.Invoice.changeset(
            invoice,
                %{
                transactionid: transactionid |> to_string,
            })
                |> Overcharge.Repo.update!
    end


    def set_invoice_status(invoice, status) do
        Overcharge.Invoice.changeset(
            invoice,
                %{
                status: status,
            })
                |> Overcharge.Repo.update!
    end


    def set_invoice_checked_out(invoice) do
        Overcharge.Invoice.changeset(
            invoice,
                %{
                is_checked_out: true,
            })
                |> Overcharge.Repo.update!
    end

    def parse_invoice_action(action) do
        [func, operator, amount, msisdn] = action |> String.split("_")
        {func, operator, amount, msisdn}
    end


    def reschedule_invoice(invoice) do
        Task.async( fn() ->
                :timer.sleep(1000*60) ## 1 minute later
                deliver(invoice)
            end)
        invoice
    end


    def handle_reason_behind_error({_gateway, errorcode}) do
        case errorcode do
            :halt ->
                :halt
            _ ->
                :not_implemented
            
        end
    end


    @doc """
        {:ok, true}
        :error
    """
    def deliver(invoice) do
         case invoice.status do
            "pending" ->
                :error
            "payed" -> 
                {func, _operator, amount, msisdn} = invoice.success_callback_action |> parse_invoice_action        
                cond do
                  func == "topup" || func == "internet" ->
                      {mode, sid, price} = case func do
                          "topup" ->
                              {1, 0, amount |> String.to_integer}
                          "internet" ->
                                {
                                    5, 
                                    amount |> String.split(":") |> List.first |> String.to_integer,
                                    amount |> String.split(":") |> List.last |> String.to_integer,
                                }
                      end |> IO.inspect
                    case Overcharge.Gasedak.topup(msisdn, price , invoice.refid, mode, sid) do  ## do charge
                        {:ok, true, transactionid} ->
                            :timer.sleep(500)
                            invoice = invoice |> set_invoice_status("processing")
                            case transactionid |> Overcharge.Gasedak.check_transaction_status(invoice.refid, msisdn) do  ## check status
                                {:ok, true} ->
                                    ivs = invoice 
                                                |> set_transactionid(transactionid)
                                                |> set_invoice_status("completed")
                                    {:ok, true, ivs }
                                {:error, errorcode} ->  ## find error
                                    case {:gasedak, errorcode} |> handle_reason_behind_error do  ## decide what to do
                                        :halt ->
                                            ivs = invoice |> set_invoice_status("payed")
                                            {:error, ivs}
                                        :reschedule ->
                                            ivs = invoice 
                                                      |> set_invoice_status("payed")
                                                      |> reschedule_invoice  ## reschedule for retrying
                                            {:error, ivs}
                                        _ ->  ## same as halt
                                            ivs = invoice |> set_invoice_status("payed")
                                            {:error, ivs} 
                                    end
                            end
                        {:error, :halt} ->
                            ivs = invoice |> set_invoice_status("debugging")
                            {:error, ivs}

                        er ->
                            er |> IO.inspect
                            IO.puts("ERRRRRRRRRRRRRRRRRRR")
                            invoice |> set_invoice_status("payed")
                            invoice |> reschedule_invoice
                            :error
                    end
                func == "pin" ->
                    :not_implemented
                true ->
                    :not_implemented
                    
                end
            "completed" ->
                {:ok, true, invoice}
            "processing" ->
                {:ok, true, invoice}
            "debugging" ->

            Task.async( fn() ->
                        :timer.sleep(1000*120) ## 1 minute later
                        invoice |> set_invoice_status("payed")
            end)
             {:error, invoice}
        end
    end


end