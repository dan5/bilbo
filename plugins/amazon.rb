# -*- encoding: UTF-8 -*-
def amazon(asin, opts = {})
  if opts[:text]
    amazon_text(asin, opts[:text])
  else
    amazon_img(asin)
  end
end

def amazon_img(asin)
  <<-HTML
    <div class="amazon">
    <iframe src="http://rcm-jp.amazon.co.jp/e/cm?t=#{config[:amazonid] or 'bilbo-22'}&o=9&p=8&l=as1&asins=#{asin}&fc1=000000&IS2=1&lt1=_blank&m=amazon&lc1=0000FF&bc1=000000&bg1=FFFFFF&f=ifr" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>
    </div>
  HTML
end

def amazon_text(asin, text)
  <<-HTML
    <a href="http://www.amazon.co.jp/o/ASIN/#{asin}/#{config[:amazonid] or 'bilbo-22'}">#{text}</a>
  HTML
end
