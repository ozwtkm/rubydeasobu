require 'webrick'
include WEBrick

module WEBrick::HTTPServlet
  FileHandler.add_handler('rb', CGIHandler)
end

# httpサーバー
s = HTTPServer.new(:BindAddress => '127.0.0.1', :DocumentRoot => '/var/www/html/testruby/', :Port => 8082 )


# サーブレット
class HelloServlet < HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res['Content-Type'] = "text/html"
    res.body = "<html><body>hello world.</body></html>"
  end
end

# サーブレットをマウント
s.mount("/hello", HelloServlet)

# Ctrl + C で停止するようにトラップを仕込む。
trap(:INT){ s.shutdown }

# サーバーを起動
s.start
