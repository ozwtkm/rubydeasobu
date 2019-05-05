#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'parallel'
require 'webrick'
require 'cgi'
include WEBrick
require_relative './_config/route'
require_relative './controller/_baseclass'
require_relative './_util/SQL_master'
require_relative './_util/SQL_transaction'
require_relative './exception/Error_404'

# httpサーバー
s = HTTPServer.new(:BindAddress => '127.0.0.1', :DocumentRoot => '/var/www/html/testruby/', :Port => 8082 )

class DispatchServlet < WEBrick::HTTPServlet::AbstractServlet

	FORK = [0] #配列長1の任意の配列
	
	def service(req, res)
	
		fork_req = req
		fork_res = res
		
		ret = Parallel.map(FORK, :in_prosess => 1) do
		
			begin
			
				klass = Routes.get_routes[fork_req.path]

				# To do:404時専用のcontrollerをつくってklass.nil?にならなくする
				if klass.nil? then
				
					raise Error_404.new
				
				end

				controller = klass.new(fork_req, fork_res)

				case fork_req.request_method 
				when "GET" then
				
					controller.get_handler()
				
				when "POST" then
				
					controller.post_handler()
				
				else
				
					controller.not_allow_handler()
				
				end

				SQL_master.commit
				SQL_transaction.commit

			rescue => e
			
				if controller.nil?
				
					fork_res.content_type = "text/html"
					fork_res.body = e.message
				
				else
				
					controller.add_exception_context(e)
					controller.view()
					
				end
				
				if e.respond_to?(:status)
			  
					fork_res.status = e.status
				
				else
				
					fork_res.status = 500
				
				end
				
			ensure
			
				SQL_master.close
				SQL_transaction.close
				
			end
			
			[fork_res.status, fork_res.body] #Parallelの戻り値
		
		end
		
		res.status = ret.first[0]
		res.body = ret.first[1]
		
	end
	
end

s.mount('/', DispatchServlet)

# Ctrl + C で停止するようにトラップを仕込む。
trap(:INT){ s.shutdown }

# サーバーを起動
s.start
