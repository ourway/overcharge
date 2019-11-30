defmodule MBTI do


    def send_message(chat_id, text, reply_markup \\ nil) do
        case reply_markup do
            nil ->
                Nadia.send_message(chat_id, text, [parse_mode: "Markdown", disable_web_page_preview: true])
            _ ->
                Nadia.send_message(chat_id, text, [reply_markup: reply_markup, parse_mode: "Markdown", disable_web_page_preview: true])
        end
    end


    def handle_incomming(id, text, _msisdn \\ nil) do
        id |> send_message(text)
    end


    def handle_callback(_id, queryid, data) do

        Nadia.answer_callback_query(queryid, [text: data])
    end
 


end