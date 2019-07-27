#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'webrick'
require 'em-websocket'
require 'cgi'
require 'cgi/session'
require_relative './_util/procedure_session'
require_relative './_config/const'

# セッション変数をwebsocketに渡すためにwebsocketにインスタンス変数を追加する。
module Ex_connection
	refine EventMachine::WebSocket::Connection do
		attr_accessor :username
		attr_accessor :unique_id
	end
end

# オフラインモード回避のためのおまじない
ENV['REQUEST_METHOD'] = 'GET'
mutex = Mutex.new

connections = {}

EM.run {
	using Ex_connection
	
	EM::WebSocket.run(:host => WEBSOCKET_ADDRESS, :port => WEBSOCKET_PORT) do |ws|
		ws.onopen { |handshake|
			begin
				header = handshake.headers
				header["cookie"]=[header["Cookie"]]#Procedure_session.get_session()をWebアプリ側と共有するにあたってのフォーマット調整

				session = Procedure_session.get_session(header)
			rescue
				send_message("require_login", ws, connections)
				next
			end
			
			ws.username = session['name']
			ws.unique_id = session.session_id()

			send_message("join", ws, connections)

			mutex.synchronize {
				connections[ws.unique_id] = ws
			}
		
		}

		ws.onmessage { |comment|
			send_message("speak", ws, connections, comment)
		}
	
		ws.onclose {
			send_message("leave", ws, connections)
			connections.delete(ws.unique_id)
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
		connections.values.each{|row|
			row.send(broadcast_msg)
		}
	end
}


