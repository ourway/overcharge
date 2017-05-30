defmodule Overcharge.ApiController do
  use Overcharge.Web, :controller
  


  def ping(conn, _params) do
       json(conn, %{message: :pong})
  end

  def mci_topup_invoice(conn, params) do
      host = Overcharge.Router.Helpers.url(conn)
      msisdn = params["msisdn"] |> Overcharge.Utils.validate_msisdn
      amount = params["amount"]
      action = "topup_mci_#{amount}_#{msisdn}"
      client = msisdn |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client)
       conn 
        #|> put_resp_header("amp-redirect-to", "https://ss2.ir/u7WJ")
        |> put_resp_header("AMP-Redirect-To", "#{host}/invoice/#{invoice.refid}")
        |> json(%{message: :pong})
  end


end