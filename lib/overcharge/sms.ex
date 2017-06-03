defmodule Overcharge.SMS do
    
    @api_key           "d7fe6790-e0d3-46f4-ae58-10d06d6b727a"
    @base_url          "https://red9.ir"

    def send_sms(number, text) do
    api_url = "#{@base_url}/api/app/messaging/send_sms_without_charge"
    data = Poison.encode! %{
            "message"           => text,
            "national_number"   => number,
            "country_code"      => 98
        }
    headers = %{ "api-key" => @api_key , "Content-Type" => "application/json; charset=utf-8"}
    HTTPoison.post(api_url, data, headers, [hackney: [:async]]) |> IO.inspect
    :queued
    end
end