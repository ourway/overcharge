defmodule Overcharge.Router do
  use Overcharge.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
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


  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end



  scope "/", Overcharge do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
    get "/deliver/:uuid", PageController, :deliver
    get "/faq", PageController, :faq
    get "/contact", PageController, :contact
    get "/about", PageController, :about
    get "/articles", PageController, :articles
    get "/invoice/:refid", PageController, :invoice
    get "/mci", PageController, :mci
    get "/mci/topup", PageController, :mci_topup
    get "/mci/rbt", PageController, :mci_rbt
    get "/irancell", PageController, :irancell
    get "/irancell/topup", PageController, :irancell_topup
    get "/irancell/internet", PageController, :irancell_internet
    get "/irancell/internet/weekly", PageController, :irancell_internet_weekly
    get "/irancell/internet/daily", PageController, :irancell_internet_daily
    get "/irancell/internet/hourly", PageController, :irancell_internet_hourly
    get "/irancell/internet/monthly", PageController, :irancell_internet_monthly
    get "/rightel", PageController, :rightel
    get "/taliya", PageController, :taliya
  end


  scope "/", Overcharge do
    pipe_through :protected
    # Add protected routes below
  end

  scope "/api", Overcharge do
    pipe_through :api
    get "/ping", ApiController, :ping
    post "/mci_topup_invoice",        ApiController, :mci_topup_invoice
    get "/get_mci_rbt",               ApiController, :get_mci_rbt
    post "/irancell_topup_invoice",   ApiController, :irancell_topup_invoice
    get "/gopay/:refid",             ApiController, :gopay
    # Add protected routes below
  end

  scope "/admin", Overcharge do
    pipe_through :admin
    get "/index", PageController, :admin
    # Add protected routes below
  end

  # Other scopes may use custom stacks.
  # scope "/api", Overcharge do
  #   pipe_through :api
  # end
end
