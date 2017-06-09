defmodule Overcharge.BotFetcher do
  use GenServer

  @cachename :overcharge_cache
  @backupname "cache_backup"
  @fetchlimit 100
  @interval 1000


  def fixes(word) do
    corrections = [
        %{ list: ["؆","؇","؈","؉","؊","؍","؎","ؐ","ؑ","ؒ","ؓ","ؔ","ؕ",
            "ؖ","ؘ","ؙ","ؚ","؞","ٖ","ٗ","٘","ٙ","ٚ","ٛ","ٜ","ٝ","ٞ","ٟ","٪",
            "٬","٭","ہ","ۂ","ۃ","۔","ۖ","ۗ","ۘ","ۙ","ۚ","ۛ","ۜ","۞","۟","۠",
            "ۡ","ۢ","ۣ","ۤ","ۥ","ۦ","ۧ","ۨ","۩","۪","۫","۬","ۭ","ۮ","ۯ","ﮧ",
            "﮲","﮳","﮴","﮵","﮶","﮷","﮸","﮹","﮺","﮻","﮼","﮽","﮾","﮿","﯀","﯁","ﱞ",
            "ﱟ","ﱠ","ﱡ","ﱢ","ﱣ","ﹰ","ﹱ","ﹲ","ﹳ","ﹴ","ﹶ","ﹷ","ﹸ","ﹹ","ﹺ","ﹻ","ﹼ","ﹽ",
            "ﹾ","ﹿ"], rep: ""}, 

    %{list:  ["أ","إ","ٱ","ٲ","ٳ","ٵ","ݳ","ݴ","ﭐ","ﭑ","ﺃ","ﺄ","ﺇ","ﺈ",
            "ﺍ","ﺎ","𞺀","ﴼ","ﴽ","𞸀"], rep: "ا"}, 
    
    %{list: ["ٮ","ݕ","ݖ","ﭒ","ﭓ","ﭔ","ﭕ","ﺏ","ﺐ","ﺑ","ﺒ","𞸁","𞸜",
            "𞸡","𞹡","𞹼","𞺁","𞺡"], rep: "ب"}, 
    
    %{list: ["ڀ","ݐ","ݔ","ﭖ","ﭗ","ﭘ","ﭙ","ﭚ","ﭛ","ﭜ","ﭝ"], rep: "پ"}, 
    %{list: ["ٹ","ٺ","ٻ","ټ","ݓ","ﭞ","ﭟ","ﭠ","ﭡ","ﭢ","ﭣ","ﭤ","ﭥ",
            "ﭦ","ﭧ","ﭨ","ﭩ","ﺕ","ﺖ","ﺗ","ﺘ","𞸕","𞸵","𞹵","𞺕","𞺵"], rep: "ت"}, 
    %{list: ["ٽ","ٿ","ݑ","ﺙ","ﺚ","ﺛ","ﺜ","𞸖","𞸶","𞹶","𞺖","𞺶"],  rep: "ث"}, 
    %{list: ["ڃ","ڄ","ﭲ","ﭳ","ﭴ","ﭵ","ﭶ","ﭷ","ﭸ","ﭹ","ﺝ","ﺞ","ﺟ",
            "ﺠ","𞸂","𞸢","𞹂","𞹢","𞺂","𞺢"], rep: "ج"}, 
    %{list: ["ڇ","ڿ","ݘ","ﭺ","ﭻ","ﭼ","ﭽ","ﭾ","ﭿ","ﮀ","ﮁ",
            "𞸃","𞺃"], rep: "چ"}, 
    %{list: ["ځ","ݮ","ݯ","ݲ","ݼ","ﺡ","ﺢ","ﺣ","ﺤ","𞸇","𞸧","𞹇","𞹧",
            "𞺇","𞺧"], rep: "ح"}, 
    %{list: ["ڂ","څ","ݗ","ﺥ","ﺦ","ﺧ","ﺨ","𞸗","𞸷","𞹗","𞹷","𞺗","𞺷"], rep: "خ"}, 
    %{list: ["ڈ","ډ","ڊ","ڌ","ڍ","ڎ","ڏ","ڐ","ݙ","ݚ","ﺩ","ﺪ","𞺣","ﮂ",
            "ﮃ","ﮈ","ﮉ"], rep: "د"}, 
    %{list: ["ﱛ","ﱝ","ﺫ","ﺬ","𞸘","𞺘","𞺸","ﮄ","ﮅ","ﮆ","ﮇ"], rep: "ذ"}, 
    %{list: ["٫","ڑ","ڒ","ړ","ڔ","ڕ","ږ","ݛ","ݬ","ﮌ","ﮍ","ﱜ","ﺭ","ﺮ",
            "𞸓","𞺓","𞺳"], rep: "ر"}, 
    %{list: ["ڗ","ڙ","ݫ","ݱ","ﺯ","ﺰ","𞸆","𞺆","𞺦"], rep: "ز"}, 
    %{list: ["ﮊ","ﮋ","ژ"], rep: "ژ"}, 
    %{list: ["ښ","ݽ","ݾ","ﺱ","ﺲ","ﺳ","ﺴ","𞸎","𞸮","𞹎","𞹮","𞺎","𞺮"], rep: "س"}, 
    %{list: ["ڛ","ۺ","ݜ","ݭ","ݰ","ﺵ","ﺶ","ﺷ","ﺸ","𞸔","𞸴","𞹔","𞹴",
            "𞺔","𞺴"], rep: "ش"}, 
    %{list: ["ڝ","ﺹ","ﺺ","ﺻ","ﺼ","𞸑","𞹑","𞸱","𞹱","𞺑","𞺱"], rep: "ص"}, 
    %{list: ["ڞ","ۻ","ﺽ","ﺾ","ﺿ","ﻀ","𞸙","𞸹","𞹙","𞹹","𞺙","𞺹"], rep: "ض"}, 
    %{list: ["ﻁ","ﻂ","ﻃ","ﻄ","𞸈","𞹨","𞺈","𞺨"], rep: "ط"}, 
    %{list: ["ڟ","ﻅ","ﻆ","ﻇ","ﻈ","𞸚","𞹺","𞺚","𞺺"], rep: "ظ"}, 
    %{list: ["؏","ڠ","ﻉ","ﻊ","ﻋ","ﻌ","𞸏","𞸯","𞹏","𞹯","𞺏","𞺯"], rep: "ع"}, 
    %{list: ["ۼ","ݝ","ݞ","ݟ","ﻍ","ﻎ","ﻏ","ﻐ","𞸛","𞸻","𞹛","𞹻","𞺛",
            "𞺻"], rep: "غ"}, 
    %{list: ["؋","ڡ","ڢ","ڣ","ڤ","ڥ","ڦ","ݠ","ݡ","ﭪ","ﭫ","ﭬ","ﭭ",
            "ﭮ","ﭯ","ﭰ","ﭱ","ﻑ","ﻒ","ﻓ","ﻔ","𞸐","𞸞","𞸰","𞹰","𞹾","𞺐","𞺰"], rep: "ف"}, 
    %{list: ["ٯ","ڧ","ڨ","ﻕ","ﻖ","ﻗ","ﻘ","𞸒","𞸟","𞸲","𞹒","𞹟","𞹲",
            "𞺒","𞺲","؈"], rep: "ق"}, 
    %{list: ["ػ","ؼ","ك","ڪ","ګ","ڬ","ڭ","ڮ","ݢ","ݣ","ݤ","ݿ","ﮎ",
            "ﮏ","ﮐ","ﮑ","ﯓ","ﯔ","ﯕ","ﯖ","ﻙ","ﻚ","ﻛ","ﻜ","𞸊","𞸪","𞹪"], rep: "ک"}, 
    %{list: ["ڰ","ڱ","ڲ","ڳ","ڴ","ﮒ","ﮓ","ﮔ","ﮕ","ﮖ","ﮗ","ﮘ","ﮙ","ﮚ",
            "ﮛ","ﮜ","ﮝ"], rep: "گ"}, 
    %{list: ["ڵ","ڶ","ڷ","ڸ","ݪ","ﻝ","ﻞ","ﻟ","ﻠ","𞸋","𞸫","𞹋","𞺋",
            "𞺫"], rep: "ل"}, 
    %{list: ["۾","ݥ","ݦ","ﻡ","ﻢ","ﻣ","ﻤ","𞸌","𞸬","𞹬","𞺌","𞺬"], rep: "م"}, 
    %{list: ["ڹ","ں","ڻ","ڼ","ڽ","ݧ","ݨ","ݩ","ﮞ","ﮟ","ﮠ","ﮡ","ﻥ","ﻦ",
            "ﻧ","ﻨ","𞸍","𞸝","𞸭","𞹍","𞹝","𞹭","𞺍","𞺭"], rep: "ن"}, 
    %{list: ["ؤ","ٶ","ٷ","ۄ","ۅ","ۆ","ۇ","ۈ","ۉ","ۊ","ۋ","ۏ","ݸ","ݹ",
            "ﯗ","ﯘ","ﯙ","ﯚ","ﯛ","ﯜ","ﯝ","ﯞ","ﯟ","ﯠ","ﯡ","ﯢ","ﯣ","ﺅ","ﺆ","ﻭ","ﻮ",
            "𞸅","𞺅","𞺥"], rep: "و"}, 
    %{list: ["ة","ھ","ۀ","ە","ۿ","ﮤ","ﮥ","ﮦ","ﮩ","ﮨ","ﮪ","ﮫ","ﮬ","ﮭ",
            "ﺓ","ﺔ","ﻩ","ﻪ","ﻫ","ﻬ","𞸤","𞹤","𞺄"], rep: "ه"}, 
    %{list: ["ؠ","ئ","ؽ","ؾ","ؿ","ى","ي","ٸ","ۍ","ێ","ې","ۑ","ے","ۓ",
            "ݵ","ݶ","ݷ","ݺ","ݻ","ﮢ","ﮣ","ﮮ","ﮯ","ﮰ","ﮱ","ﯤ","ﯥ","ﯦ","ﯧ","ﯨ",
            "ﯩ","ﯼ","ﯽ","ﯾ","ﯿ","ﺉ","ﺊ","ﺋ","ﺌ","ﻯ","ﻰ","ﻱ","ﻲ","ﻳ","ﻴ","𞸉","𞸩",
            "𞹉","𞹩","𞺉","𞺩"], rep: "ی"}, 
    %{list: ["ٴ","۽","ﺀ"], rep: "ء"}, 
    %{list: ["ﻵ","ﻶ","ﻷ","ﻸ","ﻹ","ﻺ","ﻻ","ﻼ"], rep: "لا"}]

    
  end

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
      length(target |> get_word_chars) - length(  (target |> get_word_chars |> Enum.uniq ) -- (entered |> get_word_chars) )
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
      {:ok, true} = Cachex.set(@cachename, "bot_user_#{id}_history", data)
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

def send_menu(chat_id) do
    charge = %Nadia.Model.KeyboardButton{text: "خرید شارژ", request_contact: false}
    game = %Nadia.Model.KeyboardButton{text: "شروع گیم", request_contact: false}
    markup = %Nadia.Model.ReplyKeyboardMarkup{keyboard: [[game, charge]]}
    send_message(chat_id, "انتخاب کنید", markup)
end

def send_game_menu(chat_id) do
    rules = %Nadia.Model.KeyboardButton{text: "قوانین", request_contact: false}
    help = %Nadia.Model.KeyboardButton{text: "کمک", request_contact: false}
    score = %Nadia.Model.KeyboardButton{text: "امتیاز من", request_contact: false}
    purchase = %Nadia.Model.KeyboardButton{text: "انرژی", request_contact: false}
    return = %Nadia.Model.KeyboardButton{text: "بازگشت"}
    markup = %Nadia.Model.ReplyKeyboardMarkup{keyboard: [[rules, help, score, purchase, return]]}
    send_message(chat_id, "انتخاب کنید", markup)
end


def send_rules(chat_id) do
    rule = "قواعد بازى شارژل:\n\n١- در شروع شما سختى مرحله را انتخاب ميكنيد.\n٢- سپس بايد يك كلمه به تعداد حروف درخواستى بنويسيد. مثلا اگر كلمه ٤ حرفى خواسته شده باشد بنويسيد: آرام\n\n٣- بعد از ورود كلمه نتيجه اى به شما اعلام ميشود، مثلا ٢-١. اين بدان معناست كه كلمه اى كه نوشته ايد ٢ حرف از كلمه هدف را دارد و جايگاه ١ حرف هم درست است.\n\nمثال:  فرض كنيد كلمه هدف بازى \"باران\" است. از شما خواسته ميشود يك كلمه ٥ حرفى بنويسيد.  مثلا با آرامش شروع ميكنيد، امتياز شما ميشود: ٣-٠. حرف \"ا\" و \"ر\" در كلمه هدف وجود دارد (\"ا\" دوبار در باران هست) ولى جايگاه هيچ كدام درست نيست.\n\n٤- با نوشتن كلمات به بازى ادامه دهيد تا كلمه مورد نظر را بيابيد.\n\nامتيازات:\n\n١- در شروع امتياز شما صفر است.\n٢- هر بار سعى بر پيدا كردن كلمه ١ امتياز از شما كسر ميكند.\n٣- امتياز هر كلمه در اول گيم اعلام ميشود\n٤- هر راهنمايى ١٠ امتياز از شما كسر ميكند\n٥- براى گرفتن كمك حداقل بايد ١٠ امتياز داشته باشيد.\n\nجوايز:\n\n١- اگر ٣٠٠ امتياز بدست آوريد، ١٠٠٠ تومان شارژ به شما ارسال ميشود.\n\n٢- اگر ٦٠٠ امتياز به دست آوريد، ٥٠٠٠ تومان شارژ ارسال ميشود.\n\n٣- اگر ٢٠٠٠ امتياز به دست آوريد در قرعه كشى XBox One شركت داده ميشويد.\n\nانرژى:\n\n١- ميتوانيد امتياز بخريد.  به. ازاى هر ١٠٠٠ تومن شارژ تلفن همراه كه از شارژل بخريد ١٠ امتياز به شما اضافه ميشود\n٢- هر امتياز ٣ تومان است. ميتوانيد بسته هاى ١٠٠ تومانى و ٥٠٠ تومانى امتياز ما را بخريد.\n\nموفق باشد."
    send_message(chat_id, rule)
end


def send_hint(chat_id) do
    message = "some hint"
    send_message(chat_id, message)
end


def send_score(chat_id) do
    message = "your score is some score"
    send_message(chat_id, message)
end


def send_charge_price_list(chat_id) do
    first = %Nadia.Model.KeyboardButton{text: "۱۰۰۰ تومان"}
    second = %Nadia.Model.KeyboardButton{text: "۲۰۰۰ تومان"}
    third = %Nadia.Model.KeyboardButton{text: "۵۰۰۰ تومان"}
    fourth = %Nadia.Model.KeyboardButton{text: "۱۰,۰۰۰ تومان"}
    fifth = %Nadia.Model.KeyboardButton{text: "بازگشت"}
    markup = %Nadia.Model.ReplyKeyboardMarkup{keyboard: [[first, second, third, fourth, fifth]]}
    send_message(chat_id, "انتخاب کنید", markup)
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
        _ ->
            id |> send_menu
    end
end



def action(id, :game, message) do
    case message do
        "قوانین" ->
            id |> send_rules
        "کمک" ->
            id |> send_hint
        "امتیاز من" ->
            id |> send_score
        "خرید امتیاز" ->
            id |> get_user_history |> Map.merge( %{ section:  :charge }) |> set_user_history(id)
            id |> send_charge_price_list
        "بازگشت" ->
            id |> get_user_history |> Map.merge( %{ section:  :main }) |> set_user_history(id)
            id |> send_menu
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




def game_logic(id, suggested) do
    target = id |> get_user_history |> Map.get(:target_word) |> IO.inspect
    level = id |> get_user_history |> Map.get(:level)
    score = id |> get_user_history |> Map.get(:score)
    target_score = :math.pow(2, target |> String.length) |> round
    target_punish = target |> String.length

    cond do
        (suggested |> String.length) == (target |> String.length) ->
            if is_match?(target, suggested) == true do
                    id |> get_user_history |> Map.merge( %{ score:  target_score + score }) |> set_user_history(id)
                    id |> send_message("آفرین! شما #{target_score |> convert_to_persian} امتیاز به دست آوردید و مجموع امتیاز شما به #{(target_score + score) |> convert_to_persian} رسید.")
                    id |> get_user_history |> Map.merge( %{ level:  nil }) |> set_user_history(id)
                    id |> send_game_menu
            else 
                id |> get_user_history |> Map.merge( %{ score:  score - 1 }) |> set_user_history(id)
                pos     = number_of_correct_positions(target, suggested)
                found   = number_of_found_chars(target, suggested)
                id |> send_message("نتیجه: *#{found |> convert_to_persian}*-*#{pos |> convert_to_persian}*\nامتیاز کنونی #{(score - 1) |> convert_to_persian}")
            end
        true ->
            id |> get_user_history |> Map.merge( %{ score:  score - 1 }) |> set_user_history(id)
            id |> send_message("کلمه باید #{target |> String.length |> convert_to_persian} حرفی باشد. امتیاز کنونی: #{(score - 1) |> convert_to_persian}")
    end
end



def start_game(id, level) do
    word = get_a_word(level)
    target_score = :math.pow(2, word |> String.length) |> round
    score = id |> get_user_history |> Map.get(:score)
    id |> get_user_history |> Map.merge( %{ target_word:  word }) |> set_user_history(id)
    id |> send_message("برای شروع یک کلمه *#{word |> String.length |> convert_to_persian}* حرفی به فارسی بنویسید.\n امتیاز هدف: *#{target_score |> convert_to_persian}* | امتیاز کنونی: *#{score |> convert_to_persian}*")

end

def handle_incomming(update) do
    if update |> Map.get(:message) do
        id =  update.message.chat.id
        profile = update.message.chat.id |> get_user_history |> Map.merge(
                    %{
                        username:    update.message.chat.username,
                        first_name:  update.message.chat.first_name,
                        last_name:   update.message.chat.first_name,
                        messages:    id
                                            |> get_user_history 
                                            |> Map.get(:messages) 
                                            |> List.insert_at(0, update.message.text) |> Enum.slice(0, 10)
                    }) |> set_user_history(id)
        id |> action(profile.section, update.message.text)
    end

    if update |> Map.get(:callback_query) do
        id = update.callback_query.message.chat.id
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