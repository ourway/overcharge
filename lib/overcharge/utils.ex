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
    

end