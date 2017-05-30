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


    def create_invoice(action, amount, client) do 
      amount = amount |> String.to_integer
      {:ok, invoice} = Overcharge.Invoice.changeset(
                %Overcharge.Invoice{},
                %{
                    refid: get_random_string(14),
                    description: action,
                    success_callback_action: action,
                    raw_amount: (amount*0.99) |> Float.floor |> round,
                    amount: (amount*0.99 + amount*0.09) |> Float.floor |> round
                })
               |> Ecto.Changeset.change
               |> Ecto.Changeset.put_assoc(:user, client)
        |> Overcharge.Repo.insert

        invoice
    end

end