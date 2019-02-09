#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'digest/sha1'
require 'cgi/session'
require_relative '../baseclass'
require_relative '../model/login_model'


class Login < Base

# オーバーライド。
def initialize(req,res)

	@template = "login.erb"

	super
	
	@context[:msg] = []
	
	@login_model = Login_model.new

end


def post_handler()

	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new

	super

end


def control()
	
	
	begin

		validate_special_character({:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]})

	rescue => e

		e.falselist.each do |row|
			
			@context[:msg] << "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ"
			
		end

		return

	end


	username = @req.query["name"]
	passwd = @req.query["passwd"]


	begin
	
		@login_model.check_ID_PW(@sql, username, passwd)
	
	rescue => e
		
		@context[:msg] << "IDかパスワードが違う"

		return
		
	end
		
		
	session = @login_model.login(@cgi, username)
	
	@res.header['Set-cookie'] = "session_id =" + session.session_id()
	
	@context[:msg] << username + "でログインしたった"


end


end


