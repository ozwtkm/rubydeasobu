#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'webrick'
require 'cgi'
include WEBrick
require_relative './_config/route'
require_relative './controller/baseclass'
require_relative './_util/SQL_master'
require_relative './_util/SQL_transaction'
require_relative './exception/baseclass_exception'
require_relative './exception/Error_404'

# httpサーバー
s = HTTPServer.new(:BindAddress => '127.0.0.1', :DocumentRoot => '/var/www/html/testruby/', :Port => 8082 )

class DispatchServlet < WEBrick::HTTPServlet::AbstractServlet
	def service(req, res)
	
		begin 
	
			klass = Routes::ROUTES[req.path]
	
		# To do:404時専用のcontrollerをつくってklass.nil?にならなくする
		if klass.nil? then
		
			res.content_type = "text/html"
			raise Error_404.new
		
		end

			controller = klass.new(req, res)
	
			case req.request_method 
			when "GET" then
				controller.get_handler()
			when "POST" then
				controller.post_handler()
			else
				controller.not_allow_handler()
			end
			
			rescue => e
				if controller.nil?
					res.content_type = "text/html"
					res.body = e.message
				else
					controller.add_exception_context(e)
					controller.view()
				end
					res.status = e.status
			ensure
				#SQL_master.sql.close
				#SQL_transaction.sql.close
			end
			
	end
end

s.mount('/', DispatchServlet)

# Ctrl + C で停止するようにトラップを仕込む。
trap(:INT){ s.shutdown }

# サーバーを起動
s.start
