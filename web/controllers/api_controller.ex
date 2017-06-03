defmodule Overcharge.ApiController do
  use Overcharge.Web, :controller
  


  def ping(conn, _params) do
       json(conn, %{message: :pong})
  end

  def mci_topup_invoice(conn, params) do
      host = Overcharge.Router.Helpers.url(conn)
      msisdn = params["msisdn"] |> Overcharge.Utils.validate_msisdn
      raw_amount = params["amount"] |> String.to_integer
      amount = raw_amount/1.09 |> round
      action = "topup_mci_#{raw_amount}_#{msisdn}"
      product = "شارژ مستقیم #{raw_amount} تومانی همراه اول برای +#{msisdn}"
      client = msisdn |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client, product)
       conn 
        #|> put_resp_header("amp-redirect-to", "https://ss2.ir/u7WJ")
        |> put_resp_header("AMP-Redirect-To", "#{host}/invoice/#{invoice.refid}#invoice")
        |> json(%{message: :pong})
  end



  def irancell_topup_invoice(conn, params) do
      host = Overcharge.Router.Helpers.url(conn)
      msisdn = params["msisdn"] |> Overcharge.Utils.validate_msisdn
      raw_amount = params["amount"] |> String.to_integer
      amount = raw_amount/1.09 |> round
      action = "topup_irancell_#{raw_amount}_#{msisdn}"
      product = "شارژ مستقیم #{raw_amount} تومانی ایرانسل برای +#{msisdn}"
      client = msisdn |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client, product)
       conn 
        #|> put_resp_header("amp-redirect-to", "https://ss2.ir/u7WJ")
        |> put_resp_header("AMP-Redirect-To", "#{host}/invoice/#{invoice.refid}#invoice")
        |> json(%{message: :pong})
  end

  def get_mci_rbt(conn, params) do
     page = params["page"] || 0
     data = Overcharge.Utils.get_mci_rbt_data(page)
     conn |> json(%{items: data})
  end

  def gopay(conn, params) do
      refid = params["refid"]
      gateway = Overcharge.Gasedak
      paylink = conn |> gateway.checkout(refid)
      redirect conn, external: paylink
  end



end