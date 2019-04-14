#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'digest/sha1'
require 'cgi/session'
require_relative './baseclass'
require_relative '../_util/SQL_transaction'
require_relative '../model/user'
require_relative '../exception/Error_login'

class Login < Base

# オーバーライド。
def initialize(req,res)

	@template = "login.erb"

	super
	
	@context[:msg] = []
	

end


def post_handler()

	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new

	super

end


def control()

	query = {:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]}

	exceptions = []
		
	query.each do |key,value|

		begin
		
			validate_nil(key, value)
			validate_special_character(key, value)
		
		rescue => e
		
			exceptions << e
		
		end

	end

	if !exceptions.empty?
	
		raise Error_multi_412.new(exceptions)

	end

	username = @req.query["name"]
	passwd = @req.query["passwd"]
	
	user = login(username, passwd)
	
	@context[:user] = user

end


def login(username, passwd)
	
	sql_transaction = SQL_transaction.instance.sql
	
	statement = sql_transaction.prepare("select * from transaction.users where name = ? limit 1")
	result = statement.execute(username)
	
	if result.count == 0
	
		raise Error_login.new
	
	end
	
	userinfo = result.first

	pw_hash = Digest::SHA1.hexdigest(passwd + userinfo["salt"])
	
	if pw_hash != userinfo["passwd"]
	
		raise Error_login.new
	
	end
	
	user = User.get_user(userinfo["id"])

	statement.close

	session = CGI::Session.new(@cgi,{"new_session" => true})
	session['name'] = user.name
	session['id'] = user.id
	session.close
	
	@res.header['Set-cookie'] = "session_id=" + session.session_id()
	
	return user
	
end


end
