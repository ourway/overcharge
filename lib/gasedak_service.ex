defmodule Overcharge.Gasedak do
	@base_url  "http://ws.elkapos.com/UserWebservice.asmx"

    @bank_request """
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tor="http://www.toranjsoft.com">
   <soap:Header/>
   <soap:Body>
      <tor:CreditCharge>
         <!--Optional:-->
         <tor:Username>ws115728</tor:Username>
         <!--Optional:-->
         <tor:Password>1234</tor:Password>
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
         <tor:Username>ws115728</tor:Username>
         <tor:Password>1234</tor:Password>
         <tor:MobileNumber>0<%= national_number %></tor:MobileNumber>
         <tor:Amount><%= amount*10 %></tor:Amount>
         <tor:Service>1</tor:Service>
         <tor:Params>0</tor:Params>
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
         <tor:UserName>ws115728</tor:UserName>
         <tor:Password>1234</tor:Password>
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
            %{"Note" => note, "Status" => "0", "URL" => url} ->
                {:ok, sl} = url |> Overcharge.SS2.get
                sl
            _ ->
                "/500"
        end
    end


    def topup(msisdn, amount, refid) do
        national_number =  msisdn |> String.slice(2,10)
        post = @topup_request |>  EEx.eval_string([amount: amount, refid: refid, national_number: national_number])
        resp = Overcharge.Utils.post_xml(@base_url, post)
        resp.body |> IO.inspect
        data = resp.body |> Exml.parse |> Exml.get("//RechargeResult") |> Poison.decode!
        case data do
            %{"ResultCode" => 0, "TransactionID" => trasactionid} ->
                {:ok, true, trasactionid}
            %{"ResultCode" => 5} ->

                SlackWebhook.async_send("⚠CRITICAL: Gasedak (www.elkapos.com) low credit reported while charging #{msisdn}")
                {:error, :low_credit}
            _ ->
                :error
        end
    end

    def check_transaction_status(transactionid) do
        post = @get_transaction_status |>  EEx.eval_string([transactionid: transactionid])
        resp = Overcharge.Utils.post_xml(@base_url, post)
        #resp.body |> IO.inspect
        data = resp.body |> Exml.parse |> Exml.get("//InquiryChargeResult") |> Poison.decode!
        case data do
            %{"ResultCode" => 0} ->
                SlackWebhook.async_send("⚡INFO: Gasedak. Sold a topup charge")
                {:ok, true}
            %{"ResultCode" => 9} ->
                :timer.sleep(500)
                check_transaction_status(transactionid)
            %{"ResultCode" => errorcode} ->
                {:error, errorcode}
            _ ->
                {:error, 500}
        end
    end

    def get_irancell_packages do
        case Cachex.get(:overcharge_cache, "gasedak_irancell_internet_package_list") do
            {:missing, :nil} ->
               resp = Overcharge.Utils.post_xml(@base_url, @get_internet_packages)
               data = resp.body |> Exml.parse |> Exml.get("//GetInternetPackagesResult") |> Poison.decode!
               {:ok, true} = Cachex.set(:overcharge_cache, "gasedak_irancell_internet_package_list", data)
               data
            {:ok, data} ->
                data
        end
    end



end