#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'webrick'
require 'em-websocket'
require 'cgi'
require 'cgi/session'
require_relative './_util/procedure_session'

# セッション変数をwebsocketに渡すためにwebsocketにインスタンス変数を追加する。
module Ex_connection

	refine EventMachine::WebSocket::Connection do

		attr_accessor :username

	end
	
end


# オフラインモード回避のためのおまじない
ENV['REQUEST_METHOD'] = 'GET'

mutex = Mutex.new

connections = []


EM.run {

	using Ex_connection
	
	EM::WebSocket.run(:host => "127.0.0.1", :port => 8882) do |ws|
	
		ws.onopen { |handshake|
			puts 1
			begin

				header = handshake.headers_downcased["cookie"]
				session = Procedure_session.get_session(header)

			rescue
			
				send_message("require_login", ws, connections)
			
				next
			
			end

			ws.username = session['name']

			send_message("join", ws, connections)

			mutex.synchronize {
				connections << ws
			}
		
		}


		ws.onmessage { |comment|
		
			send_message("speak", ws, connections, comment)
			
		}
	
	
		ws.onclose {

			send_message("leave", ws, connections)
			
		}
	
	end
	

	def send_message(kind, ws, connections, comment="")
	
		case kind
		when "join" then
		
			ws.send "Hello #{ws.username}"

			puts "#{ws.username}が来たみたいだよ"  
			
			broadcast_msg = "みんな～、#{ws.username}が来たみたいだぜ"
		  
		when "speak" then
		
			puts "Recieved message: #{comment} from #{ws.username}"

			broadcast_msg = "#{ws.username}「#{comment}」"
		
		when "leave" then
				
			puts "#{ws.username} が帰宅したよ"
		
			broadcast_msg = "#{ws.username}が逃げ出したぞ（逃がすな）.."
		
		when "require_login" then
		
			ws.send "ログインしろカス"
			
			return
		
		end
		
		broadcast(connections, broadcast_msg)
		
	end
	
	
	def broadcast(connections, broadcast_msg)
		
		connections.each{|conn|
		
			conn.send(broadcast_msg)
		
		}
	
	end
	
}




# 参考そーす：https://github.com/igrigorik/em-websocket