require 'webrick'
require 'optparse'
include WEBrick

module WEBrick::HTTPServlet
  FileHandler.add_handler('rb', CGIHandler)
end

=begin
OptionParser.new do |opt|
  opt.on "-d", "--[no-]daemon" do |v|
    options[:ServerType] = Daemon if v
  end

  opt.on "-p", "--port PORT", Integer do |v|
    options[:Port] = v
  end

  opt.on "-r", "--root PATH" do |v|
    options[:DocumentRoot] = v
  end

  opt.on "-l", "--log [PATH]" do |v|
    v ||= "access.log"
    path = File.expand_path(v, Dir.pwd)
    f = File.open(path, "a")
    f.sync = true
    options[:AccessLog] = [
      [f, WEBrick::AccessLog::COMBINED_LOG_FORMAT]
    ]
  end
end.parse!(ARGV)
=end

# httpサーバー
s = HTTPServer.new(:BindAddress => '127.0.0.1', :DocumentRoot => '/var/www/html/testruby/', :Port => 8082 )


# サーブレット
class HelloServlet < WEBrick::HTTPServlet::CGIHandler
  def do_GET(req, res)
  
  end
end

# サーブレットをマウント
#s.mount("/hello", HelloServlet)

routes = Hash.new

eval(File.open('./route.rb').read).each {|key, value|
  routes[key] = value
}

s.mount_proc('/') do |req, res|
	
	path = req.path.split("/")
	path.delete("")
	path = path[0].to_s
	route_path = routes[path]
	a = WEBrick::HTTPServlet::CGIHandler.new(s, "./#{route_path}")
	a.do_GET(req,res)
	
end

# s.mount('/', WEBrick::HTTPServlet::CGIHandler, './regist.rb')


# Ctrl + C で停止するようにトラップを仕込む。
trap(:INT){ s.shutdown }

# サーバーを起動
s.start
