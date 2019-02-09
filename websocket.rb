#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'em-websocket'
require 'cgi'
require 'cgi/session'
require_relative './baseclass'

# セッション変数をwebsocketに渡すためにwebsocketにインスタンス変数を追加する。
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
		
			cgi = CGI.new
			
			cgi.cookies['_session_id'] = get_sessionid(handshake)

			set_username(cgi, ws)

			messege_send("join", ws, connections)

			connections << ws
		
		}


		ws.onmessage { |comment|
		
			messege_send("speak", ws, connections, comment)
			
		}
	
	
		ws.onclose {

			messege_send("leave", ws, connections)
			
		}
	
	end
	
	
	def get_sessionid(handshake)
		
		c = handshake.headers_downcased["cookie"]
	 
		return c.match(/(^|;\s*)session_id=([a-f0-9]+)/)[2]
	
	end
	
	
	def set_username(cgi, ws)
	
		session = CGI::Session.new(cgi, {'new_session' => false})

		ws.username = (session['name'])
		
	end


	def messege_send(kind, ws, connections, comment="")
	
		case kind
		when "join" then
		
			ws.send "Hello #{ws.username}"
									
			puts "#{ws.username}が来たみたいだよ"  
			
			msg = "みんな～、#{ws.username}が来たみたいだぜ"
		  
		when "speak" then
		
			puts "Recieved message: #{comment} from #{ws.username}"
			
			msg = "#{ws.username}「#{comment}」"
		
		when "leave" then
				
			puts "#{ws.username} が帰宅したよ"
		
			msg = "#{ws.username}が逃げ出したぞ（逃がすな）.."
		
		end
		
		broadcast(connections, msg)
		
	end
	
	
	def broadcast(connections, msg)
		
		connections.each{|conn|
			conn.send(msg)
		}
	
	end
	

}





# 参考そーす：https://github.com/igrigorik/em-websocket