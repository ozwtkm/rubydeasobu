#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'webrick'
require_relative '../_util/render'
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'

class Base

def initialize(req, res)
	
	@req = req
	@res = res
	
	@sql_master = SQL_master.instance.sql
	@sql_transaction =  SQL_transaction.instance.sql
	
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

	@res.body = render(@template)

end


def validate_nil(input_hash)

	falselist = []
	input_hash.each do |key, value|
	
		if value.nil? then
		
			falselist <<key
		
		end
	
	end
	
	if !falselist.empty? then
	
		raise Input_error.new(falselist)
	
	end
	

end


def validate_special_character(input_hash)

	falselist = []
	input_hash.each do |key, value| 

		if value.match(/\A[a-zA-Z0-9_@]+\z/).nil? then
		
			falselist << key
		
		end
		
	end

	if !falselist.empty? then
	
		raise Input_error.new(falselist)
			
	end
	
end


end



# 入力値に特殊記号とかnilが来たときに使うエラー
class Input_error < StandardError
attr_reader :falselist

def initialize(list={})

	@falselist = list

end

end



