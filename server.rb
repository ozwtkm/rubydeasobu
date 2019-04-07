#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'webrick'
require 'cgi'
include WEBrick
require_relative './_config/route'
require_relative './controller/baseclass'
require_relative './_util/SQL_master'
require_relative './_util/SQL_transaction'


# httpサーバー
s = HTTPServer.new(:BindAddress => '127.0.0.1', :DocumentRoot => '/var/www/html/testruby/', :Port => 8082 )

class DispatchServlet < WEBrick::HTTPServlet::AbstractServlet
	def service(req, res)
	
		klass = Routes::ROUTES[req.path]
	
		if klass.nil? then
		
			res.content_type = "text/html"
			res.status = 404
			res.body = "404<br/><br/>" + CGI.escapeHTML(req.path) + "なんかねーよ"
			
			return
	
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
			
			#SQL_master.sql.close
			#SQL_transaction.sql.close
			
	end
end

s.mount('/', DispatchServlet)

# Ctrl + C で停止するようにトラップを仕込む。
trap(:INT){ s.shutdown }

# サーバーを起動
s.start
