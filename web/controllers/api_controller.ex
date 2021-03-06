defmodule Overcharge.ApiController do
  use Overcharge.Web, :controller


  def echo(conn, params) do
    params |> IO.inspect
    json(conn, %{message: :pong})
  end

  def ping(conn, _params) do
       json(conn, %{message: :pong})
  end

  def mci_topup_invoice(conn, params) do
      host = Overcharge.Router.Helpers.url(conn)
      #host = Overcharge.Router.Helpers.url(conn)
      msisdn = params["msisdn"] |> Overcharge.Utils.validate_msisdn
      raw_amount = params["amount"] |> String.to_integer
      amount = raw_amount/1.09 |> round
      action = "topup_mci_#{raw_amount}_#{msisdn}"
      product = "شارژ مستقیم #{raw_amount} تومانی همراه اول برای +#{msisdn}"
      client = msisdn |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client, product)
       conn 
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
        |> put_resp_header("AMP-Redirect-To", "#{host}/invoice/#{invoice.refid}#invoice")
        |> json(%{message: :pong})
  end



  def irancell_internet_invoice(conn, params) do
      host = Overcharge.Router.Helpers.url(conn)
      msisdn = params["msisdn"] |> Overcharge.Utils.validate_msisdn
      sid = params["sid"] |> String.to_integer
      raw_amount = params["amount"] |> String.to_integer
      amount = raw_amount/1.09 |> round
      action = "internet_irancell_#{sid}:#{raw_amount}_#{msisdn}"
     product =  "بسته اینترنتی ایرانسل #{Overcharge.Gasedak.get_irancell_package_info(sid, raw_amount*10)} برای +#{msisdn}"
      client = msisdn |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client, product)
       conn 
        |> put_resp_header("AMP-Redirect-To", "#{host}/invoice/#{invoice.refid}#invoice")
        |> json(%{message: :pong})
  end


  def rightel_topup_invoice(conn, params) do
      host = Overcharge.Router.Helpers.url(conn)
      msisdn = params["msisdn"] |> Overcharge.Utils.validate_msisdn
      raw_amount = params["amount"] |> String.to_integer
      amount = raw_amount/1.09 |> round
      action = "topup_rightel_#{raw_amount}_#{msisdn}"
      product =  "شارژ مستقیم #{raw_amount} تومانی رایتل برای +#{msisdn}"
      client = msisdn |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client, product)
       conn 
        |> put_resp_header("AMP-Redirect-To", "#{host}/invoice/#{invoice.refid}#invoice")
        |> json(%{message: :pong})
  end



  def mci_pin_invoice(conn, params) do
      host = Overcharge.Router.Helpers.url(conn)
      count = params["count"] |> String.to_integer
      raw_amount = 940*count
      amount = raw_amount/1.09 |> round
      action = "pin_mci_#{count}:1000_#{}"
      product =  "#{count} عدد کارت شارژ 1000 تومانی همراه اول"
      client = "980000000000" |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client, product)
       conn 
        |> put_resp_header("AMP-Redirect-To", "#{host}/invoice/#{invoice.refid}#invoice")
        |> json(%{message: :pong})
  end





  def energy_invoice(conn, params) do
      count = params["count"] |> String.to_integer
      uuid = params["uuid"]
      raw_amount = 3*count
      amount = raw_amount/1.09 |> round
      action = "energy_telegram_#{count}_#{uuid}"
      product =  "#{count} واحد انرژی گیم تلگرام شارژل"
      client = "980000000000" |> Overcharge.Utils.get_client
      invoice = Overcharge.Utils.create_invoice(action, amount, client, product)
      ivs = invoice |> Overcharge.Pay.request |> IO.inspect

      paylink = "https://pay.ir/payment/gateway/#{ivs.transactionid}"
      redirect conn, external: paylink
  end



  def get_mci_rbt(conn, params) do
     page = params["page"] || 0
     data = Overcharge.Utils.get_mci_rbt_data(page)
     conn |> json(%{items: data})
  end

  def gopay(conn, params) do
      refid = params["refid"]
      ivs = Overcharge.Utils.get_invoice(refid) |> Overcharge.Pay.request 
      paylink = "https://pay.ir/payment/gateway/#{ivs.transactionid}"
      redirect conn, external: paylink
  end


  def admin_new_post(conn, params) do
      {:ok, post} = Overcharge.Post.changeset(
            %Overcharge.Post{},
                %{
                    title: params["title"],
                    body:  params["body"],
                    is_published:  true
                }) |> Overcharge.Repo.insert
      conn |> json(%{message: :created, status: 0, uuid: post.uuid})
  end


  def admin_publish_post(conn, params) do
    (from p in Overcharge.Post,
            where: p.uuid == ^params["uuid"],
            select: p)
    |> Overcharge.Repo.one
    |> Overcharge.Post.changeset(
        %{ 
          is_published:  true
        }) 
    |> Overcharge.Repo.update!

      conn |> json(%{message: :published})
  end

  def admin_unpublish_post(conn, params) do

    (from p in Overcharge.Post,
            where: p.uuid == ^params["uuid"],
            select: p)
    |> Overcharge.Repo.one
    |> Overcharge.Post.changeset(
        %{ 
          is_published:  false
        }) 
    |> Overcharge.Repo.update!

      conn |> json(%{message: :unpublished})
  end


  def admin_delete_post(conn, params) do
        (from p in Overcharge.Post, where: p.uuid == ^params["uuid"])
        |> Overcharge.Repo.delete_all
        conn |> json(%{message: :deleted})
  end



  def admin_publish_bot(conn, params) do
      
        message = params["body"]
        members = Overcharge.Bot.find_all_members
        for m <- members do 
            Overcharge.Bot.send_message(m, message, nil) 
        end
        conn |> json(%{message: :queued, description: "will send to #{members |> length} members"})
  end


    def admin_get_bot_members_count(conn, _params) do
        members = Overcharge.Bot.find_all_members
        conn |> json(%{result: members |> length})
  end


end