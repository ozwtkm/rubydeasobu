require 'webrick'

srv = WEBrick::HTTPServer.new({
  DocumentRoot:   './',
  BindAddress:    192.168.119.128,
  Port:           88,
})

srv.start
