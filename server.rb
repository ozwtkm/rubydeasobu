require 'webrick'
require 'optparse'
include WEBrick
require_relative './route'

module WEBrick::HTTPServlet
  FileHandler.add_handler('rb', CGIHandler)
end

# httpサーバー
s = HTTPServer.new(:BindAddress => '127.0.0.1', :DocumentRoot => '/var/www/html/testruby/', :Port => 8082 )


routes = Routes::ROUTES

# dispatcherだよ
s.mount_proc('/') do |req, res|
	
	route_path = routes[req.path]
	
	if route_path == nil then
		res.content_type = "text/html"
		res.status = 404
		res.body = "404<br><br>#{req.path}なんかねーよ" #ここXSS
	else
		srv = WEBrick::HTTPServlet::CGIHandler.new(s, "./#{route_path}")
		srv.do_GET(req,res)
	end
	
end


# Ctrl + C で停止するようにトラップを仕込む。
trap(:INT){ s.shutdown }

# サーバーを起動
s.start
