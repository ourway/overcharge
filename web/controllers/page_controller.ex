defmodule Overcharge.PageController do
  use Overcharge.Web, :controller

  def index(conn, _params) do
    render conn, "index.html",
      description: "خرید ارزان و سریع شارژ ایرانسل، همراه اول و تالیا و رایتل به همراه قرعه‌کشی و جوایز",
      title:       "خرید شارژ همراه اول - ایرانسل - رایتل - تالیا",
      subtitle:    "خرید شارژ سریع و ارزان",
      color:       "#f8f8f8",
      text_color:  "#ffffff",
      page_type:   "landing",
      product:  "",
      product:  ""
  end


  ##################### MCI ###########################

  def mci(conn, _params) do
    render conn, "mci.html",
      description: "خرید ارزان و سریع شارژ مستقیم همراه اول و کارت شارژ همراه اول",
      title:       "خرید شارژ همراه اول",
      subtitle:    "خرید پین و شارژ مستقیم همراه اول",
      color:       "#e3fffe",
      text_color:  "#ffffff",
      page_type:   "shop",
      product:  "mci",
      product_fr:  "همراه اول"
  end


  def mci_topup(conn, _params) do
    render conn, "mci-topup.html",
      description: "خرید ارزان و سریع شارژ مستقیم همراه اول",
      title:       "شارژ مستقیم همراه اول",
      subtitle:    "شارژ مستقیم همراه اول",
      color:       "#e3fffe",
      text_color:  "#ffffff",
      page_type:   "product",
      product:  "mci",
      product_fr:  "همراه اول"
  end


  def mci_rbt(conn, params) do
     page = params["page"] || "0"
     data = Overcharge.Utils.get_mci_rbt_data(page)
     render conn, "mci-rbt.html",
      description: "لیست کامل آهنگ های پیشواز همراه اول",
      title:       "آوای انتظار همراه اول",
      page:        page |> String.to_integer,
      data:        data,
      subtitle:    "لیست کامل آهنگ های پیشواز همراه اول",
      color:       "#fbfbfb",
      text_color:  "#515151",
      page_type:   "list",
      product:  "mci/rbt",
      product_fr:  "آهنگ های پیشواز همراه اول"
  end




####################### IRANCELL  ##########################################

  def irancell(conn, _params) do
    render conn, "irancell.html",
      description: "خرید سریع و ارزان شارژ مستقیم و بسته های اینترنتی ایرانسل بدون نیاز به وارد کردن رمز و کد",
      title:       "خرید شارژ ایرانسل و بسته های اینترنتی ایرانسل",
      subtitle:    "خرید شارژ مستقیم و بسته های اینترنتی ایرانسل",
      color:       "#fff2a7",
      text_color:  "#333",
      page_type:   "shop",
      product:  "irancell",
      product_fr:  "ایرانسل"
  end


  def irancell_topup(conn, _params) do
    render conn, "irancell-topup.html",
      description: "خرید ارزان و سریع شارژ مستقیم ایرانسل",
      title:       "شارژ مستقیم ایرانسل",
      subtitle:    "شارژ مستقیم ایرانسل",
      color:       "#fff2a",
      text_color:  "#333",
      page_type:   "product",
      product:  "irancell",
      product_fr:  "ایرانسل"
  end


###########################################################################


  def rightel(conn, _params) do
    render conn, "rightel.html",
      description: "خرید سریع و ارزان شارژ مستقیم رایتل بدون نیاز به وارد کردن رمز و کد",
      title:       "خرید شارژ رایتل",
      subtitle:    "خرید شارژ مستقیم رایتل",
      color:       "#ffedf8",
      text_color:  "#ffffff",
      page_type:   "shop",
      product:  "rightel",
      product_fr:  "رایتل"
  end

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

    render conn, "articles.html",
      description: "مقالات و مطالب مربوط به آخرین رویدادهای مربوط به شارژ در ایران",
      title:       "مقالات شارژل",
      subtitle:    "مقالات",
      color:       "#f8f8f8",
      text_color:  "",
      page_type:   "articles",
      product:     "articles-page",
      product_fr:  "مقالات"

  end








end
