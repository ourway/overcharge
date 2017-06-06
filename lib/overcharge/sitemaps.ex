defmodule Overcharge.Sitemaps do

    use Sitemap,
    host: "https://chargell.ir",
    files_path: "web/static/assets/sitemaps/",
    public_path: "sitemaps/",
    compress: false


  def generate do
    create do
    
      for u <- [
                "/", "/همراه-اول", "/همراه-اول/شارژ-مستقیم", "/همراه-اول/کارت-شارژ", "/همراه-اول/آهنگ-پیشواز", 
                "/شارژ-رایتل",
                "/ایرانسل/topup", "/ایرانسل/internet", "/ایرانسل/بسته‌های-اینترنتی/daily", "/ایرانسل/بسته‌های-اینترنتی/monthly",  
                "/ایرانسل/بسته‌های-اینترنتی/daily/hourly"
        ] do
            add u, priority: 0.5, changefreq: "hourly"
      end


    end
  end





end