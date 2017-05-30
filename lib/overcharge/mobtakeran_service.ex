defmodule Overcharge.Mobtakeran do
	@base_url  "http://164.138.19.35:6060/TopUp/ChargeSrv.svc"

    @checkserver """
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:mrs="http://schemas.datacontract.org/2004/07/MRS.Helper.Models">
   <soapenv:Header/>
   <soapenv:Body>
      <tem:CheckServer>
         <tem:req>
            <mrs:Password>IdeR@sha</mrs:Password>
            <mrs:Username>rashauser</mrs:Username>
         </tem:req>
      </tem:CheckServer>
   </soapenv:Body>
</soapenv:Envelope>
    """

    @requestcharge """
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:mrs="http://schemas.datacontract.org/2004/07/MRS.Helper.Models">
   <soapenv:Header/>
   <soapenv:Body>
      <tem:ReserveCharge>
         <tem:req>
            <mrs:CellNumber><%= msisdn %></mrs:CellNumber>
            <mrs:ChargeType>0</mrs:ChargeType>
            <mrs:DeviceType>59</mrs:DeviceType>
            <mrs:LocalDateTime></mrs:LocalDateTime>
            <mrs:Password>IdeR@sha</mrs:Password>
            <mrs:ReserveNumber>238742947239472</mrs:ReserveNumber>
            <mrs:TotalAmount>10000</mrs:TotalAmount>
            <mrs:Username>rashauser</mrs:Username>
         </tem:req>
      </tem:ReserveCharge>
   </soapenv:Body>
</soapenv:Envelope>
    """

    @approve """
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:mrs="http://schemas.datacontract.org/2004/07/MRS.Helper.Models">
   <soapenv:Header/>
   <soapenv:Body>
      <tem:Approve>
         <tem:req>
            <mrs:Password>IdeR@sha</mrs:Password>
            <mrs:ReferenceNumber>55458621</mrs:ReferenceNumber>
            <mrs:ReserveNumber>238742947239472</mrs:ReserveNumber>
            <mrs:Username>rashauser</mrs:Username>
         </tem:req>
      </tem:Approve>
   </soapenv:Body>
</soapenv:Envelope>
    """

    @checkcharge """
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:mrs="http://schemas.datacontract.org/2004/07/MRS.Helper.Models">
   <soapenv:Header/>
   <soapenv:Body>
      <tem:CheckRequest>
         <tem:req>
             <mrs:Password>IdeR@sha</mrs:Password>
            <mrs:ReferenceNumber>48480027</mrs:ReferenceNumber>
            <mrs:ReserveNumber>238742947239472</mrs:ReserveNumber>
            <mrs:Username>rashauser</mrs:Username>
         </tem:req>
      </tem:CheckRequest>
   </soapenv:Body>
</soapenv:Envelope>
    """

    #{Calendar.DateTime.now!("Asia/Tehran") |> DateTime.to_iso8601}

end

