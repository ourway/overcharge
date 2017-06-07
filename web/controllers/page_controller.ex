defmodule Overcharge.PageController do
  use Overcharge.Web, :controller

  def index(conn, _params) do



    render conn, "index.html",
      description: "شارژ نیاز دارید؟  بسته اینترنتی لازم دارید؟  با شارژل همه چی تو سه سوت! ",
      title:       "خرید شارژ",
      subtitle:    "خرید شارژ و بسته اینترنتی همراه اول، ایرانسل و رایتل",
      color:       "#f8f8f8",
      text_color:  "#ffffff",
      page_type:   "landing",
      product:  "",
      product:  ""
  end


  ##################### MCI ###########################

  def mci(conn, _params) do
    render conn, "mci.html",
      description: "شارژ همراه اول خودتون رو از ما بخرید و کلی تخفیف هم بگیرید! همین الان شروع کنید",
      title:       "شارژ همراه اول",
      subtitle:    "خرید پین و شارژ مستقیم همراه اول",
      color:       "#e3fffe",
      text_color:  "#fff",
      page_type:   "shop",
      product:  "mci",
      product_fr:  "همراه اول"
  end


  def mci_topup(conn, params) do
    msisdn = params["msisdn"]
    amount = params["amount"] || "2000"
    render conn, "mci-topup.html",
      description: "شارژ مستقیم همراه اول میخوای؟  تو ۳ سوت شارژ میشی. شروع کن!",
      title:       "شارژ مستقیم همراه اول",
      subtitle:    "شارژ مستقیم همراه اول",
      color:       "#e3fffe",
      amount:      amount |> String.to_integer,
      msisdn:      msisdn,
      text_color:  "#fff",
      page_type:   "product",
      product:  "mci",
      product_fr:  "همراه اول"
  end


  def mci_rbt(conn, params) do
     page = params["page"] || "0"
     data = Overcharge.Utils.get_mci_rbt_data(page)
     artists = data |> Enum.map(fn(x) -> x.artist end) |> Enum.uniq
     songs = data |> Enum.map(fn(x) -> x.name end) |> Enum.uniq
     title_postfix = artists |> Enum.join(" و ")
     description_postfix = songs |> Enum.join(" ، ")
     render conn, "mci-rbt.html",
      description: "آهنگ های پیشواز همراه اول شامل #{description_postfix}",
      title:       "آوای انتظار همراه اول از #{title_postfix}",
      keywords:    artists ++ songs,
      page:        page |> String.to_integer,
      data:        data,
      subtitle:    "لیست کامل آهنگ های پیشواز همراه اول",
      color:       "#fbfbfb",
      text_color:  "#fff",
      page_type:   "shop",
      product:  "rbt",
      product_fr:  "آهنگ های پیشواز همراه اول"
  end


  def mci_pin(conn, _params) do
    render conn, "mci-pin.html",
      description: "شارژ هزار تومنی همراه اول رو با قیمیت باورنکردنی ۸۵۰ تومن بخر. ",
      title:       "کارت شارژ همراه اول",
      subtitle:    "فروش کارت شارژ 1000 تومانی همراه اول",
      color:       "#e3fffe",
      text_color:  "#fff",
      page_type:   "product",
      product:  "mci",
      product_fr:  "همراه اول"
  end



####################### IRANCELL  ##########################################

  def irancell(conn, _params) do
    render conn, "irancell.html",
      description: "ما خودمون هم ایرانسلی هستیم! بسته اینترنت ارزون و شارژ مستقیم تو سه سوت با ۲ تا کلیک! بزن بریم!",
      title:       "شارژ ایرانسل",
      subtitle:    "خرید شارژ مستقیم و بسته های اینترنتی ایرانسل",
      color:       "#fff2a7",
      text_color:  "#333",
      page_type:   "shop",
      product:  "irancell",
      product_fr:  "ایرانسل"
  end


  def irancell_topup(conn, params) do
    msisdn = params["msisdn"]
    amount = params["amount"] || "2000"
    render conn, "irancell-topup.html",
      description: "شارژ مستقیم ایرانسل اینجا سریع تر از همه جاست.  تو ۳ سوت شارژ شو",
      title:       "شارژ مستقیم ایرانسل",
      subtitle:    "شارژ مستقیم ایرانسل",
      color:       "#fff2a",
      amount:      amount |> String.to_integer,
      msisdn:      msisdn,
      text_color:  "#333",
      page_type:   "product",
      product:  "irancell",
      product_fr:  "ایرانسل"
  end


  def irancell_internet(conn, _params) do
    packages = [ 
        %{ persian: "هفتگی", en: "weekly", data: Overcharge.Gasedak.get_irancell_packages(47)},
        %{ persian:  "ماهانه", en: "monthly", data: Overcharge.Gasedak.get_irancell_packages(48)},
        %{ persian: "روزانه", en: "daily", data: Overcharge.Gasedak.get_irancell_packages(46) },
        %{ persian: "ساعتی نامحدود", en: "hourly", data: Overcharge.Gasedak.get_irancell_packages(50)},
      ]
    render conn, "irancell-internet.html",
      description: "بسته های اینترنتی ایرانسل ما هم ارزون هستن، هم بهترین ها رو واستون انتخاب کردیم!",
      title:       "بسته اینترنتی ایرانسل",
      subtitle:    "بسته های اینترنتی ایرانسل",
      color:       "#fff2a",
      packages:   packages,
      text_color:  "#333",
      page_type:   "shop",
      product:  "irancell",
      product_fr:  "بسته‌های اینترنتی ایرانسل"
  end



  def irancell_internet_package(conn, params) do
    msisdn = params["msisdn"]
    package_name = params["package_name"]
    amount = params["amount"] || "0"
    package = case package_name do
      "weekly" ->
        %{ persian: "هفتگی", en: "weekly", data: Overcharge.Gasedak.get_irancell_packages(47)}
      "monthly" ->
        %{ persian:  "ماهانه", en: "monthly", data: Overcharge.Gasedak.get_irancell_packages(48)}
      "daily" ->
        %{ persian: "روزانه", en: "daily", data: Overcharge.Gasedak.get_irancell_packages(46) }
      "hourly" ->
          %{ persian: "ساعتی نامحدود", en: "hourly", data: Overcharge.Gasedak.get_irancell_packages(50)}
    end
    #sid = 47
    #data = Overcharge.Gasedak.get_irancell_packages(sid)
    render conn, "irancell-internet-package.html",
      description: "خرید ارزان و سریع بسته اینترنتی #{package.persian} ایرانسل و اینترنت رایگان شبانه",
      title:       "بسته‌های اینترنتی #{package.persian} ایرانسل",
      subtitle:    "بسته اینترنتی #{package.persian} ایرانسل",
      color:       "#fff2a",
      #sid:        sid,
      amount:     amount |> String.to_integer,
      msisdn:     msisdn,
      package:    package,
      text_color:  "#333",
      page_type:   "product",
      product:  "irancell",
      product_fr:  "ایرانسل"
  end



###########################################################################


  def rightel(conn, params) do
    msisdn = params["msisdn"]
    amount = params["amount"] || "2000"
    render conn, "rightel.html",
      description: "خرید سریع و ارزان شارژ مستقیم رایتل بدون نیاز به وارد کردن رمز و کد",
      title:       "خرید شارژ رایتل",
      subtitle:    "خرید شارژ مستقیم رایتل",
      color:       "#ffedf8",
      amount:       amount |> String.to_integer,
      msisdn:       msisdn,
      text_color:  "#ffffff",
      page_type:   "product",
      product:  "rightel",
      product_fr:  "رایتل"
  end



########################################################  

  def taliya(conn, _params) do
    render conn, "taliya.html",
      description: "خرید سریع و ارزان شارژ مستقیم تالیا بدون نیاز به وارد کردن رمز و کد",
      title:       "خرید شارژ تالیا",
      subtitle:    "خرید شارژ مستقیم تالیا",
      color:       "#fffff",
      text_color:   "#ffffff",
      page_type:   "shop",
      product:  "taliya",
      product_fr:  "تالیا"



  end


  def admin(conn, _params) do
    render conn, "admin.html",
      description: "پنل کنترل",
      title:       "پنل ادمین",
      subtitle:    "Admin Panel",
      color:       "#fffff",
      text_color:   "",
      page_type:   "admin",
      product:  "admin",
      product_fr:  ""

  end



  def invoice(conn, params) do

    invoice = Overcharge.Utils.get_invoice(params["refid"])
    render conn, "invoice.html",
      description: "فاکتور فروش شماره #{params["refid"]}",
      invoice:     invoice,
      title:       "فاکتور #{params["refid"]}",
      subtitle:    "",
      color:       "#3366a9",
      text_color:  "",
      page_type:   "invoice",
      product:     "invoice-page",
      product_fr:  "فاکتور"

  end



  def faq(conn, _params) do

    render conn, "faq.html",
      description: "سوالات متداول در مورد خرید شارژ و پشتیبانی",
      title:       "سوالات متداول",
      subtitle:    "سوالات متداول",
      color:       "#f8f8f8",
      text_color:  "",
      page_type:   "faq",
      product:     "faq-page",
      product_fr:  "سوالات متداول"

  end



  def contact(conn, _params) do

    render conn, "contact.html",
      description: "ثبت شکایات، پشتیبانی و تماس با ما",
      title:       "تماس با ما",
      subtitle:    "با ما تماس بگیرید",
      color:       "#f8f8f8",
      text_color:  "",
      page_type:   "contact",
      product:     "contact-page",
      product_fr:  "تماس با ما"

  end

  def about(conn, _params) do

    render conn, "about.html",
      description: "شارژل سرویس سریع و با کیفیت شارژ موبایل همراه اول، ایرانسل، تالیا و رایتل است",
      title:       "درباره شارژل",
      subtitle:    "درباره شارژل",
      color:       "#f8f8f8",
      text_color:  "",
      page_type:   "about",
      product:     "about-page",
      product_fr:  "درباره شارژل"

  end


  def articles(conn, _params) do

    posts = (from p in Overcharge.Post,
            where: p.is_published == true,
            order_by: [desc: p.inserted_at],
            select: %{
              title: p.title,
              id:    p.id,
              datetime:  p.updated_at
            })
    |> Overcharge.Repo.all

    render conn, "articles.html",
      description: "مقالات و مطالب مربوط به آخرین رویدادهای مربوط به شارژ در ایران",
      title:       "مقالات شارژل",
      subtitle:    "مقالات و رویدادهای دنیای مخابرت و تلفن‌های همراه",
      posts:       posts,
      color:       "#f8f8f8",
      text_color:  "",
      page_type:   "article",
      product:     "news",
      product_fr:  "مقاله"

  end



  def article_view(conn, params) do

    post = (from p in Overcharge.Post,
            where: p.id == ^params["id"],
            where: p.is_published == true,
            select: p)
    |> Overcharge.Repo.one

    {:ok, body, []} = post.body |> Earmark.as_html
    text = body |> HtmlSanitizeEx.strip_tags

    render conn, "article_view.html",
      description: text,
      title:       post.title,
      subtitle:    post.title,
      post:       post,
      body:       body,
      text:       text,
      color:       "#f8f8f8",
      text_color:  "",
      page_type:   "article",
      product:     "news",
      product_fr:  "مقاله"

  end





    def deliver(conn, params) do

      uuid = params["uuid"]
      target = uuid |> Overcharge.Utils.get_invoice_uuid
                    |> Overcharge.Utils.set_invoice_checked_out
                     
      ivs = if target.status == "pending" do  ## only first time
              case target |> Overcharge.Pay.verify do
                1 ->
                  target |> Overcharge.Utils.set_invoice_status("payed")
                _ ->
                  target
              end
            else
              target
            end

      {code, invoice, tmpl} = case (ivs |> Overcharge.Utils.deliver) do
          {:ok, true, iv, t} ->
              {"st-001", iv, t}
          {:error, iv} ->
              {"st-002", iv, nil}
          _ ->
              {"st-003", ivs, nil}
      end


    render conn, "deliver.html",
      description: "",
      title:       "فاکتور #{invoice.refid} | تحویل کالا",
      subtitle:    "تحویل محصول",
      color:       "#fff",
      code:        code,
      tmpl:        tmpl,
      invoice:     invoice,
      text_color:  "",
      page_type:   "invoice",
      product:     "invoice-page",
      product_fr:  "تحویل کالا"

  end


  def show_invoice_pins(conn, params) do
    invoice = params["uuid"] |> Overcharge.Utils.get_invoice_uuid
    data = Overcharge.Utils.get_invoice_pins(invoice.id) 
            |> Enum.map(fn(x) -> "#{x.serial} #{x.code}" end) 
            |> Enum.join("\r\n")
    conn |> text("      SERIAL            PIN    \r\n#{data}") 
  end

  








end
