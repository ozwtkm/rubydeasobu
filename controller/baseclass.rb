#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-


require 'webrick'
require 'mysql2'
require_relative '../_util/render'

class Base


def initialize(req, res)
	
	@req = req
	@res = res
	
	@sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')
	
	# @tmplateはview時、render()に引数として渡すテンプレート。
	# Baseを引き継ぐ各クラスにて対応するテンプレート名を指定すること。
	if @template.nil?
	
		raise NotImplementedError
			
	end
		
	# view時、テンプレートに渡すための変数(ハッシュ)の箱。
	@context = {}
	
end


def get_handler()
	
	view()
	
end


def post_handler()

	control()
	view()

end


def not_allow_handler()

	@res.status = 405
	@res.body = "そのmethodだめ"

end


# オーバーライド前提。
def control()

	raise NotImplementedError

end


def view()

	view_http_header()
	view_http_body()
	
end


def view_http_header()

	@res.header['Content-Type'] = "text/html; charset=UTF-8"

end


def view_http_body()


	@res.body = render(@template, @context)

end


def validate_special_character(input_hash)

	falselist = []
	input_hash.each do |key, value| 

		if value.match(/\A[a-zA-Z0-9_@]+\z/).nil? then
		
			falselist << key
		
		end
		
	end

	if !falselist.empty? then
	
		raise Special_character_error.new(falselist)
			
	end
	
end


end



# 入力値に特殊記号が来たときに使うエラー
class Special_character_error < StandardError
attr_reader :falselist

def initialize(list)

	@falselist = list

end

end



