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

			cgi = get_sessionid(ws, handshake)

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
	
	
	def get_sessionid(ws, handshake)
	
		cgi = CGI.new
	
		c = handshake.headers_downcased["cookie"]
	 
		cgi.cookies['_session_id'] = c.match(/(^|;\s*)session_id=([a-f0-9]+)/)[2]
	
		return cgi
	
	end
	
	
	def set_username(cgi, ws)
	
		session = CGI::Session.new(cgi, {'new_session' => false})

		ws.username = (session['name'])
		
	end


	def messege_send(kind, ws, connections, comment="")
	
		case kind
		when "join" then
		
			puts "#{ws.username}が来たみたいだよ"  
		
			ws.send "Hello #{ws.username}"
		  
		when "speak" then
		
			puts "Recieved message: #{comment} from #{ws.username}"
		
		when "leave" then
				
			puts "#{ws.username} が帰宅したよ"
		
		end
		
		broadcast(kind, ws, connections, comment)
		
	end
	
	
	def broadcast(kind, ws, connections, comment)
	
		case kind
		when "join" then
		
			msg = "みんな～、#{ws.username}が来たみたいだぜ"
		
		when "speak" then
		
			msg = "#{ws.username}「#{comment}」"
		
		when "leave" then
		
			msg = "#{ws.username}が逃げ出したぞ（逃がすな）.."
		
		end
		
		connections.each{|conn|
			conn.send(msg)
		}
	
	end
	

}





# 参考そーす：https://github.com/igrigorik/em-websocket