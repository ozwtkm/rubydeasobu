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

	end
	
end

# オフラインモード回避のためのおまじない
ENV['REQUEST_METHOD'] = 'GET'

connections = []


EM.run {

	using Ex_connection
	
	EM::WebSocket.run(:host => "127.0.0.1", :port => 8882) do |ws|
	
		ws.onopen { |handshake|

			set_session(ws, handshake)	# cgiで使っているセッションの情報をwebsocketに引き継ぐ

			messege_send("join", ws, connections)

			connections << ws
		
		}


		ws.onmessage { |msg|
		
			messege_send("speak", ws, connections, msg)
			
		}
	
	
		ws.onclose {

			messege_send("logout", ws, connections)
			
		}
	
	end
	
	
	def set_session(ws, handshake)
	 	 
		cgi = CGI.new
	 
		c = handshake.headers_downcased["cookie"]
	 
		cgi.cookies['_session_id'] = c.match(/session_id=([a-f0-9]+)/)[1]
	
		session = CGI::Session.new(cgi, {'new_session' => false})

		ws.username = (session['name'])

	end


	def messege_send(kind, ws, connections, msg={})
	
		case kind
		when "join" then
		
			puts "#{ws.username}が来たみたいだよ"  
		
			ws.send "Hello #{ws.username}"
		  
			connections.each{|conn|
				conn.send("#{ws.username} 参戦！！")
		  }
		  
		when "speak" then
		
			puts "Recieved message: #{msg} from #{ws.username}"
	  
			connections.each{|conn|
				conn.send("#{ws.username} Said : #{msg}")
			}
		
		when "logout" then
				
			puts "#{ws.username} が帰宅したよ"
			
			connections.each{|conn|
				conn.send("#{ws.username}が尻尾を巻いて逃げ出した")
			}
		
		end
	
	end

}





# 参考そーす：https://github.com/igrigorik/em-websocket