#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'em-websocket'
require 'cgi'
require 'cgi/session'
require 'pry'

# セッション変数をwebsocketのインスタンスに渡すためにem-websocketをいじる
module Ex_connection
 refine EventMachine::WebSocket::Connection do
   attr_accessor :username
  
   def set_username(name)
     @username = name
   end
 end
end

ENV['REQUEST_METHOD'] = 'GET'


connections = []

EM.run {
  using Ex_connection
  EM::WebSocket.run(:host => "127.0.0.1", :port => 8882) do |ws|
     ws.onopen { |handshake|

	 cgi = CGI.new
	 
	 c = handshake.headers_downcased["cookie"]
	 puts handshake.instance_variable_get(:@headers)
	 sessionkeyvalue = c.split('=')
	 puts sessionkeyvalue
	 h = {}
	 
	 
	 sessionid = sessionkeyvalue[1]
	 
	puts sessionid
	 cgi.cookies['_session_id'] = sessionid
	 
	 session = CGI::Session.new(cgi, {"new_session" => false, "session_id" => sessionid})
	 
	 puts session.instance_variables
	 puts session['name']
	  
      puts "WebSocket connection open"

      ws.send "Hello #{session['name']} , you connected to #{handshake.path}"
	  
	  connections << ws  
      ws.set_username(session['name'])
	  
	  p connections
	  
	  connections.each{|conn|
		 conn.send("#{ws.username} 参戦！！")
	  }
    }


    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
	  p connections

	  
	  connections.each{|conn|
		conn.send("#{ws.username} Said : #{msg}")
	  }
    }
	
	ws.onclose {
	
	p "close"
	
		puts "#{ws.username} ga kaecchattamitai"
		connections.each{|conn|
			conn.send("#{ws.username}が尻尾を巻いて逃げ出した")
		}
	}
	
	
  end
}


# 参考そーす：https://github.com/igrigorik/em-websocket