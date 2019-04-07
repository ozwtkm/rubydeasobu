#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'webrick'
require 'cgi'
require 'cgi/session'
require_relative './baseclass'
require_relative '../_util/render'
require_relative '../_util/procedure_session'
require_relative '../model/user'


class Base_require_login < Base


def initialize(req, res)
	
	super
	
	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new
	
	@context[:msg] = []
	
	begin
	
		@session = Procedure_session.get_session(@cgi, @req.header["cookie"].to_s)
		@user = User.get_user(@session["name"])

	rescue
	
		@context[:msg] << "ログインしろゴミが"
	
		view()
	
	end
	
end


end

