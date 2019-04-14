#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'digest/sha1'
require 'cgi/session'
require_relative './baseclass'
require_relative '../_util/SQL_transaction'
require_relative '../model/user'

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
	error_flg = false

	begin
		
		validate_nil(query)
		
	rescue => e

		e.falselist.each do |row|
			
			@context[:msg] << "#{row}をちゃんと指定しろ。"
			
			query.delete(row)
			
		end

		error_flg = true

	end
	
	
	begin
		
		validate_special_character(query)

	rescue => e

		e.falselist.each do |row|
			
			@context[:msg] << "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ"
			
		end

		error_flg = true

	end

	# なんかキモくて嫌だが、以下の用件を満たす方法がerror_flgを用いる方法しか思いつかなかった。
	# ・クエリの片方がnilチェック、片方が特殊文字チェックで引っかかるとき、両方のエラーを伝えたい。
	if error_flg then
	
		return
	
	end

	username = @req.query["name"]
	passwd = @req.query["passwd"]

	begin
	
		user = login(username, passwd)
	
	rescue => e
		
		@context[:msg] << "IDかパスワードが違う"

		return
		
	end
	
	@context[:msg] << CGI.escapeHTML(user.name) + "でログインしたった"

end


def login(username, passwd)
	
	sql_transaction = SQL_transaction.instance.sql
	
	statement = sql_transaction.prepare("select * from transaction.users where name = ? limit 1")
	result = statement.execute(username)
	
	if result.count == 0
	
		raise
	
	end
	
	userinfo = result.first

	pw_hash = Digest::SHA1.hexdigest(passwd + userinfo["salt"])
	
	if pw_hash != userinfo["passwd"]
	
		raise
	
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
