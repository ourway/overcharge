defmodule Overcharge.Router do
  use Overcharge.Web, :router
  #use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    #plug :protect_from_forgery   ## disabled because of pay.ir posts
    plug :put_secure_browser_headers
    #plug Coherence.Authentication.Session
  end


  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Overcharge.Admin
  end


  pipeline :api do
    plug :accepts, ["json"]
    plug Overcharge.CORS
  end

  pipeline :admin_api do
    plug :accepts, ["json"]
    plug Overcharge.CORS
    plug Overcharge.Admin
  end


  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    #plug Coherence.Authentication.Session, protected: true
  end

  scope "/" do
    pipe_through :browser
    #coherence_routes
  end

  scope "/" do
    pipe_through :protected
    #coherence_routes :protected
  end



  scope "/", Overcharge do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
    get "/deliver/:uuid", PageController, :deliver
    post "/deliver/:uuid", PageController, :deliver
    get "/faq", PageController, :faq
    get "/contact", PageController, :contact
    get "/about", PageController, :about
    get "/articles", PageController, :articles
    get "/articles/:id/:title", PageController, :article_view
    get "/invoice/:refid", PageController, :invoice
    get "/mci", PageController, :mci
    get "/همراه-اول", PageController, :mci
    get "/mci/topup", PageController, :mci_topup
    get "/همراه-اول/شارژ-مستقیم", PageController, :mci_topup
    get "/mci/pin", PageController, :mci_pin
    get "/همراه-اول/کارت-شارژ", PageController, :mci_pin
    get "/mci/rbt", PageController, :mci_rbt
    get "/همراه-اول/آهنگ-پیشواز", PageController, :mci_rbt
    get "/irancell", PageController, :irancell
    get "/ایرانسل", PageController, :irancell
    get "/ایرانسل/شارژ-مستقیم", PageController, :irancell_topup
    get "/irancell/internet", PageController, :irancell_internet
    get "/ایرانسل/بسته‌های-اینترنتی", PageController, :irancell_internet
    get "/irancell/internet/:package_name", PageController, :irancell_internet_package
    get "/ایرانسل/بسته‌های-اینترنتی/:package_name", PageController, :irancell_internet_package
    get "/rightel/topup", PageController, :rightel
    get "/شارژ-رایتل", PageController, :rightel
    get "/taliya", PageController, :taliya
    get "/show_invoice_pins/:uuid", PageController, :show_invoice_pins
  end


  scope "/", Overcharge do
    pipe_through :protected
    # Add protected routes below
  end

  scope "/api", Overcharge do
    pipe_through :api
    get "/ping",                              ApiController, :ping
    post "/mci_topup_invoice",                ApiController, :mci_topup_invoice
    get "/energy_invoice/:uuid/:count",      ApiController, :energy_invoice
    options "/mci_topup_invoice",             ApiController, :mci_topup_invoice
    post "/mci_pin_invoice",                  ApiController, :mci_pin_invoice
    get "/get_mci_rbt",                       ApiController, :get_mci_rbt
    post "/irancell_topup_invoice",           ApiController, :irancell_topup_invoice
    options "/irancell_topup_invoice",        ApiController, :irancell_topup_invoice
    post "/irancell_internet_invoice/:sid",   ApiController, :irancell_internet_invoice
    options "/irancell_internet_invoice/:sid",ApiController, :irancell_internet_invoice
    post "/rightel_topup_invoice",            ApiController, :rightel_topup_invoice
    options "/rightel_topup_invoice",         ApiController, :rightel_topup_invoice
    get "/gopay/:refid",                      ApiController, :gopay
    # Add protected routes below
  end


  scope "/bot", Overcharge do
    pipe_through :api
    post "/", ApiController, :echo
  end

  scope "/admin", Overcharge do
    pipe_through :admin
    get "/index", PageController, :admin
    # Add protected routes below
  end

  scope "/admin/api", Overcharge do
    pipe_through :admin_api
    get       "/ping",                       ApiController, :ping
    post      "/post/new",                   ApiController, :admin_new_post
    patch     "/post/publish/:uuid",         ApiController, :admin_publish_post
    patch     "/post/unpublish/:uuid",       ApiController, :admin_unpublish_post
    delete    "/post/delete/:uuid",          ApiController, :admin_delete_post
    post      "/bot/broadcast",              ApiController, :admin_publish_bot

  end



  # Other scopes may use custom stacks.
  # scope "/api", Overcharge do
  #   pipe_through :api
  # end
end
