#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'webrick'
require_relative '../_util/render'
require_relative '../_util/log'
require_relative '../_util/validator'
require_relative '../exception/Error_multi_412'

class Base
# ステータスコード
OK = 200
CREATED = 201
RESET_CONTENT = 205


def initialize(req, res)
	@req = req
	@res = res
	@URLquery = []
	set_URLquery()

	# @tmplateはview時、render()に引数として渡すテンプレート。
	# Baseを引き継ぐ各クラスにて対応するテンプレート名を指定すること。
	if @template.nil?
		raise NotImplementedError
	end
		
	# view時、テンプレートに渡すための変数(ハッシュ)の箱。
	@context = {}

	validate_input()
end

def get_handler()
	get_control()
	view()
end

def post_handler()
	post_control()
	view()
end

def put_handler()
	put_control()
	view()
end

def delete_handler()
	delete_control()
	view()
end

def not_allow_handler()
	@res.status = 405
	@res.body = "そのmethodだめ"
end

# オーバーライド前提。
def get_control()
	raise NotImplementedError
end

# オーバーライド前提。
def post_control()
	raise NotImplementedError
end

# オーバーライド前提。
def put_control()
	raise NotImplementedError
end

# オーバーライド前提。
def delete_control()
	raise NotImplementedError
end

def view()
	view_http_header()
	view_http_body()
end

def view_http_header()
	@res.header['Content-Type'] = "application/json; charset=UTF-8"
end

def view_http_body()
	@res.body = render(@template)
end

def add_exception_context(e)
	@context[:e] = e
end

def set_URLquery()
	@req.path_info.each do |row|
		@URLquery << row
	end
end

def validate_input()
	@json = JSON.parse(@req.body) unless @req.body.nil?
	case @req.request_method
	when "GET"
		validate_get_input()
	when "POST"
		validate_post_input()
	when "PUT"
		validate_put_input()
	when "DELETE"
		validate_delete_input()
	end
end

def validate_get_input()
	# オーバーライドすること
end

def validate_post_input()
	# オーバーライドすること
end

def validate_put_input()
	# オーバーライドすること
end

def validate_delete_input()
	# オーバーライドすること
end


end
