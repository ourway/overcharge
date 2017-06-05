defmodule Overcharge.Sitemaps do

    use Sitemap,
    host: "https://chargell.ir",
    files_path: "web/static/assets/sitemaps/",
    public_path: "sitemaps/",
    compress: false


  def generate do
    create do
    
      for u <- [
                "/", "/mci", "/mci/topup", "/mci/pin", "/mci/rbt", "/taliya/topup", "/rightel/topup",
                "/irancell/topup", "/irancell/internet", "/irancell/internet/daily", "/irancell/internet/monthly",  
                "/irancell/internet/daily/hourly"
        ] do
            add u, priority: 0.5, changefreq: "hourly"
      end


    end
  end





end