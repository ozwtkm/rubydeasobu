require 'webrick'
include WEBrick

module WEBrick::HTTPServlet
  FileHandler.add_handler('rb', CGIHandler)
end

# http�T�[�o�[
s = HTTPServer.new(:DocumentRoot => '/var/www/html/testruby/', :Port => 8082 )


# �T�[�u���b�g
class HelloServlet < HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res['Content-Type'] = "text/html"
    res.body = "<html><body>hello world.</body></html>"
  end
end

# �T�[�u���b�g���}�E���g
s.mount("/hello", HelloServlet)

# Ctrl + C �Œ�~����悤�Ƀg���b�v���d���ށB
trap(:INT){ s.shutdown }

# �T�[�o�[���N��
s.start