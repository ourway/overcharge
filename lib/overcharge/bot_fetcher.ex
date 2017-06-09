defmodule Overcharge.BotFetcher do
  use GenServer

  @cachename :overcharge_cache
  @backupname "cache_backup"
  @fetchlimit 100
  @interval 500


  def convert_to_persian(digits) do
      digits |> to_string 
        |> String.replace("0", "۰") 
        |> String.replace("1", "۱") 
        |> String.replace("2", "۲") 
        |> String.replace("3", "۳") 
        |> String.replace("4", "۴") 
        |> String.replace("5", "۵") 
        |> String.replace("6", "۶") 
        |> String.replace("7", "۷") 
        |> String.replace("8", "۸") 
        |> String.replace("9", "۹") 
        |> String.replace("-", "منفی ") 
  end



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
      end |> Persian.fix
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
      length(target |> get_word_chars) - length(  (target |> get_word_chars ) -- (entered |> get_word_chars) )
  end

  def is_match?(target, entered) do
      target == entered
  end

  def get_cache_offset do
    case Cachex.get(@cachename, "telegram_bot_last_update_id") do
            {:missing, nil} ->
                -1
            {:ok, k} ->
                k
        end
  end


  def find_all_members do
      for k <- Cachex.keys!(@cachename) do
          try do
            "bot_user_history_" <> i  = k
                i |> String.to_integer
           rescue
               MatchError ->
                0
           end
      end |> Enum.filter(fn(x) -> x != 0 end)
  end


  def broadcast_message(text) do
        for member <- find_all_members do
            send_message(member, text)
        end
  end

  def get_user_history(id) do
      case Cachex.get(@cachename, "bot_user_history_#{id}") do
            {:ok, history} ->
                history
            {:missing, nil} ->
                %{
                    id: id,
                    messages: [],
                    msisdn:   nil,
                    score: 0,
                    level: nil,
                    section: :main,
                    uuid: Ecto.UUID.generate |> to_string,
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
      {:ok, true} = Cachex.set(@cachename, "bot_user_history_#{id}", data)
      data
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
        try do
            update |> handle_incomming
        rescue 
           _ ->
                :continue
        end
    end

    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval ) # 5 seconds
  end




################# handle #####################


def send_message(id, text, reply_markup \\ nil, delay \\ 10) do
    Process.send_after(self(), {:send_message, id, text, reply_markup}, delay)
end


def send_levels(chat_id) do
    easy = %Nadia.Model.InlineKeyboardButton{text: "آسان", callback_data: "level_easy", url: ""}
    mid = %Nadia.Model.InlineKeyboardButton{text: "متوسط", callback_data: "level_mid", url: ""}
    hard = %Nadia.Model.InlineKeyboardButton{text: "سخت", callback_data: "level_hard", url: ""}
    markup = %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: [[easy, mid, hard]]}
    send_message(chat_id, "سختی بازی رو انتخاب کنید", markup, 1000)
end

def send_menu(chat_id) do
    #charge = %Nadia.Model.KeyboardButton{text: "خرید شارژ", request_contact: false}
    game = %Nadia.Model.KeyboardButton{text: "شروع گیم", request_contact: false}
    markup = %Nadia.Model.ReplyKeyboardMarkup{keyboard: [[game]], one_time_keyboard: false, resize_keyboard: true}
    send_message(chat_id, "انتخاب کنید", markup)
end

def send_game_menu(chat_id) do
    rules = %Nadia.Model.KeyboardButton{text: "قوانین", request_contact: false}
    help = %Nadia.Model.KeyboardButton{text: "کمک", request_contact: false}
    gift = %Nadia.Model.KeyboardButton{text: "جایزه", request_contact: true}
    score = %Nadia.Model.KeyboardButton{text: "امتیاز", request_contact: false}
    purchase = %Nadia.Model.KeyboardButton{text: "انرژی", request_contact: false}
    return = %Nadia.Model.KeyboardButton{text: "<-"}
    markup = %Nadia.Model.ReplyKeyboardMarkup{keyboard: [[rules, help, score, gift, purchase, return]], resize_keyboard: true, one_time_keyboard: false}
    send_message(chat_id, "<---->", markup)
end


def send_rules(chat_id) do
    rule = "قواعد بازى شارژل:\nبرای راهنمایی /help را میتوانید بزنید\n\n١- در شروع شما سختى مرحله را انتخاب ميكنيد.\n٢- سپس بايد يك كلمه به تعداد حروف درخواستى بنويسيد. مثلا اگر كلمه ٤ حرفى خواسته شده باشد بنويسيد: آرام\n\n٣- بعد از ورود كلمه نتيجه اى به شما اعلام ميشود، مثلا ٢-١. اين بدان معناست كه كلمه اى كه نوشته ايد ٢ حرف از كلمه هدف را دارد و جايگاه ١ حرف هم درست است.\n\nمثال:  فرض كنيد كلمه هدف بازى \"باران\" است. از شما خواسته ميشود يك كلمه ٥ حرفى بنويسيد.  مثلا با آرامش شروع ميكنيد، امتياز شما ميشود: ٣-٠. حرف \"ا\" و \"ر\" در كلمه هدف وجود دارد (\"ا\" دوبار در باران هست) ولى جايگاه هيچ كدام درست نيست.\n\n٤- با نوشتن كلمات به بازى ادامه دهيد تا كلمه مورد نظر را بيابيد.\n\nامتيازات:\n\n١- در شروع امتياز شما صفر است.\n٢- هر بار سعى بر پيدا كردن كلمه ۱ تا ۱۰ امتياز از شما كسر ميكند.\n٣- امتياز هر كلمه در اول گيم اعلام ميشود\n٤- هر راهنمايى ١٠ امتياز از شما كسر ميكند\n٥- براى گرفتن كمك حداقل بايد ١٠ امتياز داشته باشيد.\n\nجوايز:\n\n١- اگر ٣٠٠ امتياز بدست آوريد، ١٠٠٠ تومان شارژ به شما ارسال ميشود.\n\n٢- اگر ٦٠٠ امتياز به دست آوريد، ٥٠٠٠ تومان شارژ ارسال ميشود.\n\n٣- اگر ٢٠٠٠ امتياز به دست آوريد در قرعه كشى XBox One شركت داده ميشويد.\n\nانرژى:\n\n١- ميتوانيد امتياز بخريد.  به. ازاى هر ١٠٠٠ تومن شارژ تلفن همراه كه از شارژل بخريد ١٠ امتياز به شما اضافه ميشود\n٢- هر امتياز ٣ تومان است. ميتوانيد بسته هاى ١٠٠ تومانى و ٥٠٠ تومانى امتياز ما را بخريد.\n\nموفق باشد."
    send_message(chat_id, rule)
end

def reveal_word(chat_id) do
    target = chat_id |> get_user_history |> Map.get(:target_word)
    score = chat_id |> get_user_history |> Map.get(:score)
    chat_id |> get_user_history |> Map.merge( %{ score: score - 20 }) |> set_user_history(chat_id)
    chat_id |> get_user_history |> Map.merge( %{ level:  nil }) |> set_user_history(chat_id)
    chat_id |> get_user_history |> Map.merge( %{ target_word:  nil }) |> set_user_history(chat_id)
    chat_id |> send_message("کلمه هدف *#{target}* بود!")
end


def send_hint(chat_id) do
    target = chat_id |> get_user_history |> Map.get(:target_word)
    score = chat_id |> get_user_history |> Map.get(:score)
    message =   if score >= 10 do
                    chat_id |> get_user_history |> Map.merge( %{ score: score - 10 }) |> set_user_history(chat_id)
                    c = target |> get_word_chars |> Enum.random
                    "کلمه هدف *#{c}* دارد!"
                else
                    "برای راهنمایی حداقل ۱۰ امتیاز نیاز دارید"
                end
        
    send_message(chat_id, message)
    chat_id |> send_game_menu
end


def send_score(chat_id) do
    score = chat_id |> get_user_history |> Map.get(:score)
    message = "شما *#{score |> convert_to_persian }* امتیاز دارید."
    send_message(chat_id, message)
end

def send_gift(chat_id) do
    score = chat_id |> get_user_history |> Map.get(:score)
    msisdn = chat_id |> get_user_history |> Map.get(:msisdn)
    refid = chat_id |> get_user_history |> Map.get(:uuid)
    cond do
        score < 300 ->
            send_message(chat_id, "برای دریافت جایزه حداقل به ۳۰۰ امتیاز نیاز دارید.")
        score > 300 && score < 600 ->
            chat_id |> get_user_history |> Map.merge( %{ score: score - 300 }) |> set_user_history(chat_id)
            Overcharge.Gasedak.topup(msisdn, 1000 , refid, 1, 0) 
            send_message(chat_id, "شارژ ۱۰۰۰  تومانی برای شما ارسال شد.")
        score > 600 && score < 2000 ->
            chat_id |> get_user_history |> Map.merge( %{ score: score - 600 }) |> set_user_history(chat_id)
            Overcharge.Gasedak.topup(msisdn, 5000 , refid, 1, 0) 
            send_message(chat_id, "شارژ ۵۰۰۰  تومانی برای شما ارسال شد.")
        score > 2000 ->
            chat_id |> get_user_history |> Map.merge( %{ score: score - 2000 }) |> set_user_history(chat_id)
            chat_id |> get_user_history |> Map.merge( %{ lottery: true }) |> set_user_history(chat_id)
            #Overcharge.Gasedak.topup(msisdn, 5000 , refid, 1, 0) 
            send_message(chat_id, "شما در قرعه‌کشی XBox One شرکت داده شدید.")
    end
end


def send_charge_price_list(chat_id) do
    first = %Nadia.Model.KeyboardButton{text: "۱۰۰۰ تومان"}
    second = %Nadia.Model.KeyboardButton{text: "۲۰۰۰ تومان"}
    third = %Nadia.Model.KeyboardButton{text: "۵۰۰۰ تومان"}
    fourth = %Nadia.Model.KeyboardButton{text: "۱۰,۰۰۰ تومان"}
    fifth = %Nadia.Model.KeyboardButton{text: "بازگشت"}
    markup = %Nadia.Model.ReplyKeyboardMarkup{keyboard: [[first, second, third, fourth, fifth]], one_time_keyboard: false, resize_keyboard: true}
    send_message(chat_id, "انتخاب کنید", markup)
end


def send_energy_list(chat_id) do
    easy = %Nadia.Model.InlineKeyboardButton{text: "۴۰ امتیاز", url: "https://chargell.ir/api/energy_invoice/#{chat_id}/40"}
    mid = %Nadia.Model.InlineKeyboardButton{text: "۱۰۰ امتیاز", url: "https://chargell.ir/api/energy_invoice/#{chat_id}/100"}
    hard = %Nadia.Model.InlineKeyboardButton{text: "۵۰۰ امتیاز", url: "https://chargell.ir/api/energy_invoice/#{chat_id}/500"}
    markup = %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: [[easy, mid, hard]]}

   send_message(chat_id, "بسته انرژی خود را انتخاب کنید", markup)
end



def action(id, :main, message) do
    case message do
        "شروع گیم" ->
            id |> get_user_history |> Map.merge( %{ section:  :game }) |> set_user_history(id)
            id |> send_levels
            id |> send_game_menu
        "خرید شارژ" ->
            id |> get_user_history |> Map.merge( %{ section:  :charge }) |> set_user_history(id)
            id |> send_charge_price_list
        "lets_broadcast_it" ->
            id |> get_user_history |> Map.merge( %{ section:  :broadcast }) |> set_user_history(id)
        _ ->
            id |> send_menu
    end
end


def action(id, :broadcast, message) do
      broadcast_message(message)
      id |> get_user_history |> Map.merge( %{ section:  :main }) |> set_user_history(id)
      id |> send_message("sent to all")
end



def action(id, :game, message) do
    case message do
        "شروع گیم" ->
            id |> get_user_history |> Map.merge( %{ section:  :game }) |> set_user_history(id)
            id |> send_game_menu
            id |> send_levels
        "/new" ->
            id |> get_user_history |> Map.merge( %{ section:  :game }) |> set_user_history(id)
            id |> send_game_menu
            id |> send_levels
        "/backoff" ->
            id |> get_user_history |> Map.merge( %{ section:  :game }) |> set_user_history(id)
            id |> reveal_word
            id |> send_levels
        "/start" ->
            id |> send_rules
        "/gift" ->
            id |> send_gift
        "قوانین" ->
            id |> send_rules
        "کمک" ->
            id |> send_hint
        "/help" ->
            id |> send_rules
        "/hint" ->
            id |> send_hint
        "امتیاز" ->
            id |> send_score
        "انرژی" ->
            #id |> get_user_history |> Map.merge( %{ section:  :energy }) |> set_user_history(id)
            id |> send_energy_list
        "خرید امتیاز" ->
            id |> get_user_history |> Map.merge( %{ section:  :charge }) |> set_user_history(id)
            id |> send_charge_price_list
        "بازگشت" ->
            id |> get_user_history |> Map.merge( %{ target_word: nil }) |> set_user_history(id)
            id |> get_user_history |> Map.merge( %{ section:  :main }) |> set_user_history(id)
            id |> send_menu
        "<-" ->
            id |> get_user_history |> Map.merge( %{ target_word: nil }) |> set_user_history(id)
            id |> get_user_history |> Map.merge( %{ section:  :game }) |> set_user_history(id)
            id |> send_game_menu
            id |> send_levels
        _ ->
            id |> game_logic(message)
            #id |> get_user_history |> Map.merge( %{ section:  :main }) |> set_user_history(id)
            #id |> send_menu
    end
end



def action(id, :charge, message) do
    case message do
        "بازگشت" ->
            id |> get_user_history |> Map.merge( %{ section:  :main }) |> set_user_history(id)
            id |> send_menu
        _ ->
            id |> send_message("not yet")
    end
end


def action(id, :energy, message) do
    case message do
        "بازگشت" ->
            id |> get_user_history |> Map.merge( %{ section:  :game }) |> set_user_history(id)
            id |> send_menu
        _ ->
            id |> send_message("not yet")
    end
end

def game_logic(_id, nil) do
    :ok
end


def game_logic(id, word) do
    suggested = word |> Persian.fix
    target = id |> get_user_history |> Map.get(:target_word)

    if target do
            level = id |> get_user_history |> Map.get(:level)
            score = id |> get_user_history |> Map.get(:score)
            {id, score, level, target, suggested} |> IO.inspect
            target_score = :math.pow(2, target |> String.length) |> round
            target_punish = case level do
                :nil ->
                    0
                :easy ->
                    1
                :mid ->
                    4
                :hard ->
                    10
            end

            cond do
                (suggested |> String.length) == (target |> String.length) ->
                    if is_match?(target, suggested) == true do
                            id |> get_user_history |> Map.merge( %{ score:  target_score + score }) |> set_user_history(id)
                            id |> send_message("آفرین! شما #{target_score |> convert_to_persian} امتیاز به دست آوردید و مجموع امتیاز شما به #{(target_score + score) |> convert_to_persian} رسید.")
                            id |> get_user_history |> Map.merge( %{ level:  nil }) |> set_user_history(id)
                            id |> send_levels
                    else 
                        id |> get_user_history |> Map.merge( %{ score:  score - target_punish }) |> set_user_history(id)
                        pos     = number_of_correct_positions(target, suggested)
                        found   = number_of_found_chars(target, suggested)
                        id |> send_message("نتیجه: *#{found |> convert_to_persian}*-*#{pos |> convert_to_persian}*\nامتیاز کنونی #{(score - target_punish) |> convert_to_persian} | عقب‌ نشینی با /backoff")
                    end
                true ->
                    id |> get_user_history |> Map.merge( %{ score:  score - 1 }) |> set_user_history(id)
                    id |> send_message("کلمه باید #{target |> String.length |> convert_to_persian} حرفی باشد. امتیاز کنونی: #{(score - 1) |> convert_to_persian}. \n راهنمایی /help")
            end
    end
end



def start_game(id, level) do
    #markup = %Nadia.Model.ReplyKeyboardHide{hide_keyboard: true}
    word = get_a_word(level)
    target_score = :math.pow(2, word |> String.length) |> round
    score = id |> get_user_history |> Map.get(:score)
    id |> get_user_history |> Map.merge( %{ target_word:  word }) |> set_user_history(id)
    id |> send_message("برای شروع یک کلمه *#{word |> String.length |> convert_to_persian}* حرفی به فارسی بنویسید.\n امتیاز هدف: *#{target_score |> convert_to_persian}* | امتیاز کنونی: *#{score |> convert_to_persian}*")
end

def handle_incomming(update) do
    if update |> Map.get(:message) do
        id =  update.message.chat.id
        history = update.message.chat.id |> get_user_history |> Map.merge(
                    %{
                        username:    update.message.chat.username,
                        first_name:  update.message.chat.first_name,
                        last_name:   update.message.chat.last_name,
                        messages:    id
                                            |> get_user_history 
                                            |> Map.get(:messages) 
                                            |> List.insert_at(0, case update.message.text do
                                                                    nil ->
                                                                        ""
                                                                    "" ->
                                                                        ""
                                                                    t ->
                                                                        t |> Persian.fix
                                                                 end) |> Enum.slice(0, 10) })
                                                                      |> set_user_history(id)
       case update |> Map.get(:message) |> Map.get(:contact) do
            nil ->
                id |> action(history.section, update.message.text)
            c ->
                profile = id |> get_user_history 
                                |> Map.merge( %{ msisdn: c.phone_number })
                                |> set_user_history(id)
               profile.id |> action(history.section, "/gift")
        end
        
    end

    if update |> Map.get(:callback_query) do
        id = update.callback_query.message.chat.id
        #id |> send_game_menu
        query_id = update.callback_query.id
        data = update.callback_query.data

        case data do
            "level_easy" ->
                id |> get_user_history |> Map.merge( %{ level:  :easy }) |> set_user_history(id)
                id |> start_game(:easy)
            "level_mid" ->
                id |> get_user_history |> Map.merge( %{ level:  :mid }) |> set_user_history(id)
                id |> start_game(:mid)
            "level_hard" ->
                id |> get_user_history |> Map.merge( %{ level:  :hard }) |> set_user_history(id)
                id |> start_game(:hard)
        end
        Nadia.answer_callback_query(query_id, [text: "باشه"])
    end


    
end




end