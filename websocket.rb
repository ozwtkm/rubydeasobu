#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'em-websocket'
require 'cgi'
require 'cgi/session'

ENV['REQUEST_METHOD'] = 'GET'

#cgi = CGI.new
#session = CGI::Session.new(cgi, {'new_session' => true})
#sessionid = session.session_id
#session['name'] = "buriburi"
#session.close

#p sessionid

#session.close

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
	 
	  #p sessionid
	  #p session
	  puts session['name'] + "　ga yattekitamitai"
	  #p ENV
	  #ws.data = session['name']
	  
      puts "WebSocket connection open"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      ws.send "Hello #{session['name']} , you connected to #{handshake.path}"
	  
	  connections << ws
	  p ws
	  p ws.instance_variables
	  p ws.instance_variable_get(:@handler)
	  p @handler
	  #p ws.data.class
	  
	  connections.each{|conn|
		 conn.send("#{session['name']} 参戦！！")
	  }
    }



    ws.onmessage { |msg|
      #puts "Recieved message: #{msg}"

#		 cgi = CGI.new
#     c = handshake.headers_downcased['cookie']
#	 sessionkeyvalue = c.split('=')
#	 h = {}
#	 h[sessionkeyvalue[0]] = sessionkeyvalue[1]
#	 
#	 sessionid = h['_session_id']
#	 cgi.cookies['_session_id'] = sessionid
#	 
#	 session = CGI::Session.new(cgi, {'new_session' => false})

	  
	  connections.each{|conn|
		conn.send("#{session['name']} Said : #{msg}")
	  }
    }
	
	ws.onclose {
	
#		 cgi = CGI.new
#     c = handshake.headers_downcased['cookie']
#	 sessionkeyvalue = c.split('=')
#	 h = {}
#	 h[sessionkeyvalue[0]] = sessionkeyvalue[1]
#	 
#	 sessionid = h['_session_id']
#	 cgi.cookies['_session_id'] = sessionid
#	 
#	 session = CGI::Session.new(cgi, {'new_session' => false})
#	
	
		puts session['name'] + "　ga kaecchattamitai"
		connections.each{|conn|
			conn.send("#{session['name']} が　尻尾を巻いて逃げ出しました")
		}
	}
	
	
  end
}

# 参考そーす：https://github.com/igrigorik/em-websocket
