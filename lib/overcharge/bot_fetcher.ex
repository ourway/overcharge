defmodule Overcharge.BotFetcher do
  use GenServer

  @cachename :overcharge_cache
  @backupname "cache_backup"
  @fetchlimit 100
  @interval 1000



  def get_a_word(level) do
      initial = :ets.lookup(:wordlist, level) |> List.first |> Tuple.to_list |> List.last |> Enum.random
      cond  do
          initial |> String.last == "ي" ->
              get_a_word(level)
          initial |> String.last == "ی" ->
              get_a_word(level)
           initial |> String.last != "ي" ->
                initial
           initial |> String.last != "ی" ->
                initial
           true ->
               get_a_word(level)
      end
  end


  def get_word_chars(word) do
      for i <- 1..(word |> String.length) do word |> String.slice(i-1, 1) end |> Enum.reverse
  end

  def set_last_update_id(num) do
      {:ok, true} = Cachex.set(@cachename, "telegram_bot_last_update_id", num)
  end

  def number_of_correct_positions(target, entered) do
      Enum.zip(target |> get_word_chars, entered |> get_word_chars) |> Enum.filter(fn({a, b}) -> a == b end) |> length
  end

  def number_of_found_chars(target, entered) do
      length(target |> get_word_chars) - length(  (target |> get_word_chars) -- (entered |> get_word_chars) )
  end

  def get_cache_offset do
    case Cachex.get(@cachename, "telegram_bot_last_update_id") do
            {:missing, nil} ->
                -1
            {:ok, k} ->
                k
        end
  end

  def get_user_history(id) do
      case Cachex.get(@cachename, "bot_user_#{id}_history") do
            {:ok, history} ->
                history
            {:missing, nil} ->
                %{
                    id: id,
                    messages: [],
                    msisdn:   nil,
                    score: 0,
                    level: nil,
                    suggested_correct: [],
                    target_word: nil,
                    username: nil,
                    first_name: nil,
                    last_name: nil,
                    last_command: nil
                }
      end
  end

  def set_user_history(data, id) do
      {:ok, true} = Cachex.set(@cachename, "bot_user_#{id}_history", data)
  end


  def get_updates do

        case Nadia.get_updates limit: @fetchlimit, offset: (get_cache_offset + 1) do
            {:error, %Nadia.Model.Error{reason: :nxdomain}} ->
                {:ok, []}
            
            {:ok, data} ->
                {:ok, data}
            _ ->
                {:ok, []}
        end
  end


  def get_latest_update_id(data) do
    ui = case data |> List.last do
        nil ->
            get_cache_offset
        l ->
            l |> Map.get(:update_id)
    end
     ui |> dump_cache_to_disk
     ui
  end


  def dump_cache_to_disk(last_update_id) do
    case last_update_id |> rem(10) do
        0 ->
            {:ok, true} = Cachex.dump(@cachename, @backupname)
        _ ->
            :continue
    end
  end






  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    ## load wordlist
    :ets.new(:wordlist, [:named_table])   ## create new ets table
    {:ok, wordlist} = File.read!("wordlist.json") |> Poison.decode
    true = :ets.insert(:wordlist, {:easy, wordlist |> Map.get("fours")})
    true = :ets.insert(:wordlist, {:mid, wordlist |> Map.get("sixes")})
    true = :ets.insert(:wordlist, {:hard, wordlist |> Map.get("tens")})


    case Cachex.load(@cachename, @backupname) do
        {:error, :unreachable_file} ->
            Cachex.dump(@cachename, @backupname)
        {:ok, true} ->
            :ok
    end
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end


  def handle_info({:send_message, target, message, reply_markup}, state) do
      case reply_markup do
          nil ->
            Nadia.send_message(target, message, [parse_mode: "Markdown", disable_web_page_preview: true])
          _ ->
            Nadia.send_message(target, message, [reply_markup: reply_markup, parse_mode: "Markdown", disable_web_page_preview: true])
      end
    {:noreply, state}
  end




  def handle_info(:work, state) do

    {:ok, data} = get_updates
    data |> get_latest_update_id |> set_last_update_id

    for update <- data do
        update |> handle_incomming
    end

    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval ) # 5 seconds
  end




################# handle #####################


def send_message(id, text, reply_markup \\ nil) do
    Process.send_after(self(), {:send_message, id, text, reply_markup}, 10)
end


def send_levels(chat_id) do
    easy = %Nadia.Model.InlineKeyboardButton{text: "آسان", callback_data: "level_easy", url: ""}
    mid = %Nadia.Model.InlineKeyboardButton{text: "متوسط", callback_data: "level_mid", url: ""}
    hard = %Nadia.Model.InlineKeyboardButton{text: "سخت", callback_data: "level_hard", url: ""}
    markup = %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: [[easy, mid, hard]]}
    send_message(chat_id, "سختی بازی رو انتخاب کنید", markup)
end






def handle_incomming(update) do

    if update |> Map.get(:message) do
        id = update.message.chat.id
        past_history = id |> get_user_history
        past_history |> Map.merge(
                    %{
                        username:    update.message.chat.username,
                        first_name:  update.message.chat.first_name,
                        last_name:   update.message.chat.first_name,
                        messages:    past_history.messages |> List.insert_at(0, update.message.text) |> Enum.slice(0, 10)
                    }) |> set_user_history(id)

        #send_message(id, "*ok*\nDone")
        send_levels(id)
    end

    if update |> Map.get(:callback_query) do
        query_id = update.callback_query.id
        data = update.callback_query.data

        ## answer
        Nadia.answer_callback_query(query_id, [text: "باشه"])
    end


    
end




end