#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'em-websocket'
require 'cgi'
require 'cgi/session'


connections = []

EM.run {
  EM::WebSocket.run(:host => "127.0.0.1", :port => 8882) do |ws|
     ws.onopen { |handshake|

      p ENV

      exit

      puts "WebSocket connection open"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      ws.send "Hello Client, you connected to #{handshake.path}"
	  
	  connections << ws
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
	  
	  connections.each{|conn|
		conn.send(msg)
		conn.send(session['name'])
	  }
    }
  end
}

# 参考そーす：https://github.com/igrigorik/em-websocket
