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






########################################################################

  def irancell(conn, _params) do
    render conn, "irancell.html",
      description: "خرید سریع و ارزان شارژ مستقیم و بسته های اینترنتی ایرانسل بدون نیاز به وارد کردن رمز و کد",
      title:       "خرید شارژ ایرانسل",
      subtitle:    "خرید شارژ مستقیم و بسته های اینترنتی ایرانسل",
      color:       "#fff2a7",
      text_color:  "#333",
      page_type:   "shop",
      product:  "irancell",
      product_fr:  "ایرانسل"
  end

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
      subtitle:    "",
      color:       "#fffff",
      text_color:   "#ffffff",
      page_type:   "admin",
      product:  "",
      product_fr:  ""

  end



  def invoice(conn, params) do
    
    render conn, "invoice.html",
      description: "",
      title:       "",
      subtitle:    "",
      color:       "",
      text_color:  "",
      page_type:   "",
      product:  "",
      product_fr:  ""

  end





end
