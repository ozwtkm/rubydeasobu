#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'webrick'
require 'cgi'
require 'cgi/session'
require_relative './_baseclass'
require_relative '../_util/render'
require_relative '../_util/procedure_session'
require_relative '../model/user'

class Base_require_login < Base

def initialize(req, res)	
	super
	
	@session = Procedure_session.get_session(@req.header) 
	@user = User.get_user(@session["id"]) # id←sessionidじゃなくてuseridね。
	@context[:user] = @user
end

end

