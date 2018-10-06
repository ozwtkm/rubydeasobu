#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'em-websocket'
require 'cgi'
require 'cgi/session'


ENV['REQUEST_METHOD'] = 'GET'




connections = []

EM.run {
  EM::WebSocket.run(:host => "127.0.0.1", :port => 8882) do |ws|
     ws.onopen { |handshake|

	 cgi = CGI.new
     c = handshake.headers_downcased['cookie']
	 sessionkeyvalue = c.split('=')
	 h = {}
	 h[sessionkeyvalue[0]] = sessionkeyvalue[1]
	 
	 sessionid = h['_session_id']
	 cgi.cookies['_session_id'] = sessionid
	 
	 session = CGI::Session.new(cgi, {'new_session' => false})
	 
	  puts session['name'] + "　ga yattekitamitai"
	  
      puts "WebSocket connection open"

      ws.send "Hello #{session['name']} , you connected to #{handshake.path}"
	  
	  connections << ws  
	        p connections
      ws.instance_variable_set(:@username, session['name'])
	  
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