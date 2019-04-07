#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-

require 'webrick'
require 'cgi'
require 'cgi/session'
require_relative './baseclass'
require_relative '../_util/render'
require_relative '../_util/procedure_session'

class Base_require_login < Base

def initialize(req, res)
	
	super
	
	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new
	
	@context[:msg] = []
	
end


def get_handler()
	
	begin
	
		@session = Procedure_session.get_session(@cgi, @req.header["cookie"].to_s)
	
	rescue
	
		@context[:msg] << "ログインしろゴミが"
		
		super
		
	end

	@context[:msg] << "ようこそ" + @session['name'] + "さん"

	super

end


def post_handler()
	
	begin
	
		@session = Procedure_session.get_session(@cgi, @req.header["cookie"].to_s)

	rescue
	
		@context[:msg] << "ログインしろゴミが"
	
		view()
		
		return
	
	end

	super

end


end


