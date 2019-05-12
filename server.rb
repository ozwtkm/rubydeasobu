#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'parallel'
require 'webrick'
require 'cgi'
include WEBrick
require_relative './_config/route'
require_relative './_config/const'
require_relative './controller/_baseclass'
require_relative './_util/SQL_master'
require_relative './_util/SQL_transaction'
require_relative './exception/Error_404'


# httpサーバー
s = HTTPServer.new(:BindAddress => '127.0.0.1', :DocumentRoot => ROOTPATH, :Port => 8082)

class DispatchServlet < WEBrick::HTTPServlet::AbstractServlet
	DUMMY_ITEMS = [nil] #配列長1の任意の配列
	INTERNAL_SERVER_ERROR = 500
	@@routes = Routes.get_routes
	
	def service(req, res)
		finishProc = Proc.new { |item, index, result|
			res.status = result[0]
			res.body = result[1]
			result[2].each do |key,val|
				res.header[key]=val
			end
		}
		
		#最大フォーク数が1(0を指定すると現在のプロセス上で実行されてしまうので注意)
		Parallel.map(DUMMY_ITEMS, :in_prosess => 1, :finish => finishProc) {
			begin
				req.path_info = separate(req.path) #RESTfulにしたい。
				controller = createController(req, res)
				dispatch(controller, req.request_method)
				SQL_master.commit
				SQL_transaction.commit
			rescue => e
				setErrorHttpStatus(res, e)
				setErrorBody(res, controller, e)
			ensure
				SQL_master.close
				SQL_transaction.close
			end
			
			[res.status,res.body,res.header] #finishProcのresultに入る
		}
	end
	
	def separate(path)
		path = path.split("/")
		path.shift()
		
		return path
	end
	
	def createController(req, res)
		klass = @@routes["/"+req.path_info.first]

		if klass.nil? then
			raise Error_404.new
		end
		
		controller = klass.new(req, res)
	end
	
	def dispatch(controller, method)
		case method 
		when "GET" then
			controller.get_handler()
		when "POST" then
			controller.post_handler()
		else
			controller.not_allow_handler()
		end
	end
	
	def setErrorHttpStatus(res, e)
		if !e.respond_to?(:status)
			res.status = INTERNAL_SERVER_ERROR
			
			return
		end
		
		res.status = e.status.to_i
	end
	
	def setErrorBody(res, controller, e)
		if controller.nil?
			res.content_type = "text/html"
			res.body = e.message

			return
		end

		controller.add_exception_context(e)
		controller.view()
	end
end

s.mount('/', DispatchServlet)
trap(:INT){ s.shutdown }
trap(:TERM){ s.shutdown }
s.start
