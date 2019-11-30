defmodule Sitemaps do

    use Sitemap,
    host: "https://www.chargell.com",
    files_path: "web/static/assets/sitemaps/",
    public_path: "sitemaps/",
    compress: false


  def generate do
    create do
    
      for u <- [
                "/",
                "/ایرانسل",
                "/ایرانسل/شارژ-مستقیم",
                "/ایرانسل/بسته‌های-اینترنتی",
                "/همراه-اول",
                "/همراه-اول/شارژ-مستقیم",
                "/همراه-اول/کارت-شارژ",
                "/شارژ-رایتل",
                "/contact",
                "/faq",
                "/about",
                "/articles"
        ] do
            add u, priority: 0.5, changefreq: "hourly"
      end


    end
  end





end