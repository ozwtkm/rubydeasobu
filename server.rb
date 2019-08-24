#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'logger'
require 'parallel'
require 'webrick'
require 'cgi'
include WEBrick
require_relative './_config/route'
require_relative './_config/const'
require_relative './controller/_baseclass'
require_relative './_util/log'
require_relative './_util/cache'
require_relative './_util/documentDB'
require_relative './_util/SQL_master'
require_relative './_util/SQL_transaction'
require_relative './_util/environment'
require_relative './exception/Error_404'


module Output
	def self.console_and_file(defout)
		class << defout
			alias_method :write_org, :write
			def write(str)
				STDOUT.write(str)
				self.write_org(str)
			end
		end
	end
end

develop_or_production = ARGV[0]
Environment.set(develop_or_production)

address = Environment.webrick_address()
documentroot = Environment.rootpath()
port = Environment.webrick_port()
path_log = Environment.path_log()

f_access = File.open(path_log + 'server.log', 'a')
Output.console_and_file(f_access)

number_of_log_files = 5
size_of_file = 1 * 1024 * 1024

log_access = Logger.new(f_access, number_of_log_files, size_of_file)

# httpサーバー
s = HTTPServer.new(
	:BindAddress => address, :DocumentRoot => documentroot, :Port => port,
	:Logger => log_access,
	:AccessLog => [
		[log_access, WEBrick::AccessLog::COMMON_LOG_FORMAT],
		[log_access, WEBrick::AccessLog::REFERER_LOG_FORMAT]
	]
)

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
				Log.log(e)
				Log.log(e.backtrace.join("\n"))
				setErrorHttpStatus(res, e)
				setErrorBody(res, controller, e)
			ensure
				Cache.close
				DocumentDB.close
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
		when "PUT" then
			controller.put_handler()
		when "DELETE" then
			controller.delete_handler()
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

def shutdown(server, logfile)
	logfile.close
	server.shutdown
end

Log.set_log(f_access)
s.mount('/', DispatchServlet)

trap(:INT){ shutdown(s, f_access) }
trap(:TERM){ shutdown(s, f_access) }

s.start




