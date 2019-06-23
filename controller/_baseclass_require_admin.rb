#!/usr/bin/ruby -Ku 
# -*- coding: utf-8 -*-
require 'webrick'
require 'cgi'
require 'cgi/session'
require_relative './_baseclass'
require_relative '../_util/render'
require_relative '../_util/procedure_session'
require_relative '../model/admin_user'

class Base_require_admin < Base

def initialize(req, res)	
	super
	
	@session = Procedure_session.get_session(@req.header,admin: true) 
	@user = Admin_user.get(@session["id"]) # id←sessionidじゃなくてuseridね。
	@context[:user] = @user
end

end

