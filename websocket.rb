#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-


require 'em-websocket'
require 'cgi'
require 'cgi/session'
require_relative './baseclass'

# セッション変数をwebsocketのインスタンスに渡すためにem-websocketをいじり、
# 
module Ex_connection
	refine EventMachine::WebSocket::Connection do
	
		attr_accessor :username

		def set_username(name)
			@username = name
		end
		
	end
	
end

# オフラインモード回避のためのおまじない
ENV['REQUEST_METHOD'] = 'GET'

connections = []


EM.run {
	using Ex_connection
	EM::WebSocket.run(:host => "127.0.0.1", :port => 8882) do |ws|
		ws.onopen { |handshake|

			cgi = CGI.new
		 
			c = handshake.headers_downcased["cookie"]
			sessionkeyvalue = c.split('=')
			h = {}
			sessionid = sessionkeyvalue[1]
		 
			cgi.cookies['_session_id'] = sessionid
		
			session = CGI::Session.new(cgi, {'new_session' => false})

			ws.set_username(session['name'])

			ws.send "Hello #{ws.username} , you connected to #{handshake.path}"

			puts "#{ws.username}が来たみたいだよ"  
		  
			connections.each{|conn|
				conn.send("#{ws.username} 参戦！！")
		  }

			connections << ws
		
		}

		ws.onmessage { |msg|
		
			puts "Recieved message: #{msg} from #{ws.username}"
	  
			connections.each{|conn|
				conn.send("#{ws.username} Said : #{msg}")
			}
			
		}
	
	
		ws.onclose {
		
			puts "#{ws.username} が帰宅したよ"
			
			connections.each{|conn|
				conn.send("#{ws.username}が尻尾を巻いて逃げ出した")
			}
			
		}
	
	end

}


# 参考そーす：https://github.com/igrigorik/em-websocket