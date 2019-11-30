defmodule Overcharge.Gasedak do
	#@base_url  "http://ws.elkapos.com/UserWebservice.asmx"
	@base_url  "http://ws.toshanet.ir/UserWebservice.asmx"

    @bank_request """
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tor="http://www.toranjsoft.com">
   <soap:Header/>
   <soap:Body>
      <tor:CreditCharge>
         <!--Optional:-->
         <tor:Username>ws17110</tor:Username>
         <!--Optional:-->
         <tor:Password>Cc_183060</tor:Password>
         <tor:Amount><%= amount*10 %></tor:Amount>
         <!--Optional:-->
         <tor:CallBackURL><%= host %>/deliver/<%= invoice_uuid %>#form?_ref=gasedak</tor:CallBackURL>
      </tor:CreditCharge>
   </soap:Body>
</soap:Envelope>
    """

    @topup_request """
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tor="http://www.toranjsoft.com">
   <soap:Header/>
   <soap:Body>
      <tor:Recharge>
         <tor:Username>ws17110</tor:Username>
         <tor:Password>Cc_183060</tor:Password>
         <tor:MobileNumber>0<%= national_number %></tor:MobileNumber>
         <tor:Amount><%= amount*10 %></tor:Amount>
         <tor:Service><%= mode %></tor:Service>
         <tor:Params><%= service_id %></tor:Params>
         <tor:UserOrderID><%= refid %></tor:UserOrderID>
      </tor:Recharge>
   </soap:Body>
</soap:Envelope>
    """


    @get_transaction_status """
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tor="http://www.toranjsoft.com">
   <soap:Header/>
   <soap:Body>
      <tor:InquiryCharge>
         <tor:UserName>ws17110</tor:UserName>
         <tor:Password>Cc_183060</tor:Password>
         <tor:TransactionID><%= transactionid %></tor:TransactionID>
      </tor:InquiryCharge>
   </soap:Body>
</soap:Envelope>    
    """

    @get_internet_packages """
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tor="http://www.toranjsoft.com">
   <soap:Header/>
   <soap:Body>
      <tor:GetInternetPackages>
         <tor:OperatorID>1</tor:OperatorID>
      </tor:GetInternetPackages>
   </soap:Body>
</soap:Envelope>
    """




    def checkout(conn, refid) do
        host = Overcharge.Router.Helpers.url(conn)
        invoice = Overcharge.Utils.get_invoice(refid) 
        post = @bank_request |>  EEx.eval_string([amount: invoice.amount, host: host, invoice_uuid: invoice.uuid])
        resp = Overcharge.Utils.post_xml(@base_url, post)
        {:ok, result} = resp.body |> Exml.parse |> Exml.get("//CreditChargeResult") |> Poison.decode
        case result do
            %{"Note" => _note, "Status" => "0", "URL" => url} ->
                {:ok, sl} = url |> Overcharge.SS2.get
                sl
            _ ->
                "/500"
        end
    end

    @doc """
        topup: 
            mode: 1
            sid: 0
        internet:
            mode: 5,
            sid: sid
    """
    def topup(msisdn, amount, refid, mode \\ 1, sid \\ 0) do
        national_number =  msisdn |> String.slice(2,10)
        post = @topup_request |>  EEx.eval_string(
                [
                    amount:             amount,
                    refid:              refid,
                    service_id:         sid,
                    mode:               mode,
                    national_number:    national_number
                ])
        resp = Overcharge.Utils.post_xml(@base_url, post)
        resp.body |> IO.inspect
        data = resp.body |> Exml.parse |> Exml.get("//RechargeResult") |> Poison.decode!
        case data do
            %{"ResultCode" => 0, "TransactionID" => trasactionid} ->
                {:ok, true, trasactionid}
            %{"ResultCode" => 13} ->  ## duplicated orderID
                {:error, :halt}
            %{"ResultCode" => 5} ->
                SlackWebhook.async_send("⚠CRITICAL: Gasedak (www.elkapos.com) low credit reported while charging #{msisdn}")
                Overcharge.SMS.send_sms("9120228207", "Chargell.com\nToshanet Low credit.\n #{msisdn} faild to charge #{amount} tomans.")
                {:error, :low_credit}
            _ ->
                :error
        end
    end

    def check_transaction_status(transactionid, refid, msisdn) do
        post = @get_transaction_status |>  EEx.eval_string([transactionid: transactionid])
        resp = Overcharge.Utils.post_xml(@base_url, post)
        national_number =  msisdn |> String.slice(2,10)
        #resp.body |> IO.inspect
        data = resp.body |> Exml.parse |> Exml.get("//InquiryChargeResult") |> Poison.decode!
        case data do
            %{"ResultCode" => 0} ->
                SlackWebhook.async_send("⚡INFO: Gasedak: Sold a topup charge")
                {:ok, true}

            %{"ResultCode" => 9} ->
                :timer.sleep(500)
                check_transaction_status(transactionid, refid, msisdn)
            %{"ResultCode" => errorcode} ->
                SlackWebhook.async_send("⚠CRITICAL: Gasedak: Charge Failed for #{national_number}. refid: #{refid}")
                Overcharge.SMS.send_sms("9120228207", "Chargell.com\nToshanet Charge Error.\n #{msisdn} failed to charge.\nRefid: #{refid}")
                Overcharge.SMS.send_sms(national_number, "مشتری گرامی، مشکل عدم شارژ شما در حال پیگیری است.\n\nRefid: #{refid}")
                {:error, errorcode}
            _ ->
                {:error, 500}
        end
    end

    def get_irancell_packages(sid) do
        case Cachex.get(:overcharge_cache, "gasedak_irancell_internet_package_list") do
            {:missing, :nil} ->
               resp = Overcharge.Utils.post_xml(@base_url, @get_internet_packages)
               data = resp.body |> Exml.parse |> Exml.get("//GetInternetPackagesResult") |> Poison.decode!
               {:ok, true} = Cachex.set(:overcharge_cache, "gasedak_irancell_internet_package_list", data)
               data
            {:ok, data} ->
                data
        end 
          |> Enum.filter_map(fn(x) -> x["ServiceID"] == sid end,
                &( %{   
                        description:    &1["ServiceName"] 
                                            |> String.replace(
                                                &1["ServicePrice"] |> div(10) |> to_string,
                                                &1["ServicePrice"]/1.09 |> round |> div(10) |> to_string),
                        price: &1["ServicePrice"],
                        section: &1["ProfileName"],
                        sid:  &1["ServiceID"]
                    } )
          ) |> (&([ %{
                count: length(&1),
                minmax:  Enum.min_max_by(&1, fn(x) -> x.price end)
                          |> Tuple.to_list
                          |> Enum.map(fn(k) -> k.price/1.09 |> round end )
                }] ++ &1)).()
    end

    def get_irancell_package_info(sid, amount) do
        Overcharge.Gasedak.get_irancell_packages(sid) 
                |> Enum.slice(1,10) 
                |> Enum.filter_map(
                    fn(x) -> x |> Map.get(:price) == amount end,
                    &(&1.description))
                |> List.first
    end



end