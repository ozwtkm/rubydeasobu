require 'webrick'
require 'mysql2'
require_relative './render'

class Base

METHOD_GET = 0
METHOD_POST = 1
RESULT_SPECIAL_CHARACTER_ERROR = 0


def initialize(req,res)

	@req = req
	@res = res
	
	@sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')
	
	# view時、テンプレートに渡すための変数(ハッシュ)の箱 
	@context = {}
	
end


def view(status={})

	view_http_header()
	view_http_body(status)
	
end


def view_http_header()

	@res.header['Content-Type'] = "text/html; charset=UTF-8"

end



# オーバーライドする前提。
def view_http_body(status={})

	raise NotImplementedError

end


def validate_special_character(input_hash)

	falselist = []
	input_hash.each do |key, value| 

		if value.match(/\A[a-zA-Z0-9_@]+\z/) == nil then
		
			falselist << key
		
		end
		
	end	

	if falselist != [] then
	
		raise Special_character_error.new(falselist)
			
	end
	
end


# オーバーライドするぜんてい
def get_handler()
	
	view()
	
end


# オーバーライドするぜんてい
def post_handler()

	view()

end


def not_allow_handler()

	@res.status = 405
	@res.body = "そのmethodだめ"

end


end



# 入力値に特殊記号が来たときに使うエラー
class Special_character_error < StandardError
attr_reader :falselist

def initialize(list)

	@falselist = list

end

end



