require 'em-websocket'

connections = []

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8882) do |ws|
    ws.onopen { |handshake|
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
	  }
    }
  end
}

# 参考そーす：https://github.com/igrigorik/em-websocket