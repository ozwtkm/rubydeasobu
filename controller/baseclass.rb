#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'webrick'
require_relative '../_util/render'
require_relative '../_util/validator'
require_relative '../exception/Error_multi_412'

class Base

def initialize(req, res)
	
	@req = req
	@res = res
	
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


def add_exception_context(e)

	@context[:e] = e

end


end


