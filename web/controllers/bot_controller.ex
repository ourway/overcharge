defmodule Overcharge.BotController do
  use Overcharge.Web, :controller
  @chargell_bot_token   "396811502:AAGK-M5KH9yJBSzC72RiY6lC7OelWvh06Ws"
  @mbti_bot_token       "407642344:AAG70Dp1mggFzUv8wNmzsMbvZ8oe7OWVB7s"


  def bot(conn, %{"bot_token" => token,
        "callback_query" => %{ "data" => data, "from" => %{"id" => id}, "id" => queryid}}) do

    case token do
        @chargell_bot_token ->
            Overcharge.Bot.handle_callback(id, queryid, data)
        @mbti_bot_token ->
                MBTI.handle_callback(id, queryid, data)
        _ ->
            :not_implemented
    end
    conn |> json(%{status: true})
  end



    def bot(conn, %{
      "bot_token" => token,
      "message" => %{"chat" => %{"id" => id}, "text" => text}}) do
        {id, text} |> IO.inspect
        case token do
            @chargell_bot_token ->
                Overcharge.Bot.handle_incomming(id, nil, nil, nil, text)
            @mbti_bot_token ->
                MBTI.handle_incomming(id, text)
            _ ->
                :not_implemented
            
        end
        conn |> json(%{status: true})

    end


    def bot(conn, %{"bot_token" => token,
          "message" => %{ "chat" => %{"id" => id},
          "contact" => %{ "phone_number" => msisdn} }}) do
          
        {id, msisdn} |> IO.inspect
        case token do
            @chargell_bot_token ->
                Overcharge.Bot.handle_incomming(id, nil, nil, nil, nil, msisdn)
            @mbti_bot_token ->
                MBTI.handle_incomming(id, nil, msisdn)
            _ ->
                :not_implemented
        end
        conn |> json(%{status: true})

      end


  def bot(conn, params) do
        params |> IO.inspect
      conn |> json(%{status: true})
  end





end