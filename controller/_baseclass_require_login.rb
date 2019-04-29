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

	@session = Procedure_session.get_session(@req.header["cookie"][0]) # @req.header["cookie"].class が Arrayなので[0]で文字列として取得
	@user = User.get_user(@session["id"]) # id←sessionidじゃなくてuseridね。
	
end

end

