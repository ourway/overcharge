defmodule Overcharge.Sitemaps do

    use Sitemap,
    host: "https://overcharge.ir",
    files_path: "priv/static/sitemaps/",
    public_path: "sitemaps/",
    compress: false


  def generate do
    create do
    
      for u <- [
                "/", "/mci", "/mci/topup", "/mci/pin", "/taliya/topup", "/rightel/topup",
                "/irancell/topup", "/irancell/internet"
        ] do
            add u, priority: 0.5, changefreq: "hourly"
      end


    end
  end





end