#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'cgi/session'
require_relative './baseclass'
	
class Login < Base


def post_handler()

	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new
	control()
	view()
	
end


# 入力→viewの流れの核となる処理。
def control()
	
	
	# 何はともあれまずは入力値検証
	begin

		validate_special_character({:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]})

	rescue => e

		@context[:msg] = ""

		e.falselist.each do |row|
			
			@context[:msg] += "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ<br>"
			
		end

		return

	end


	username = @req.query["name"]
	passwd = @req.query["passwd"]


	# ログインできる認証情報か？の検証
	begin
	
		check_ID_PW(username, passwd)
	
	rescue => e
		
		@context[:msg] = "IDかパスワードが違う"

		return
		
	end
		
		
	session = login(username)

	login_user_name = session.instance_variable_get(:@data)["name"]
	
	@context[:msg] = CGI.escapeHTML(login_user_name) + "でログインしたった"
		
	return

end


def check_ID_PW(username, passwd)
	
	# ログイン可能な入力組み合わせかチェックする。（入力値組に合致するレコードの個数を返す）
	statement = @sql.prepare("select salt from users2 where name = ? limit 1")
	result_tmp = statement.execute(username)
	
	
	# result_tmp[0]で処理したいができなかった
	result = nil
	result_tmp.each do |row|
		result = row
	end
	
	
	if result == nil
	
		raise
	
	end
	
	
	pw_hash = Digest::SHA1.hexdigest(passwd + result["salt"])
	
	statement = @sql.prepare("select * from users2 where name = ? and passwd = ? limit 1")
	result_tmp = statement.execute(username, pw_hash)

	result=nil
	result_tmp.each do |row|
		result = row
	end
	
	
	if result == nil
	
		raise
	
	end

end


def login(username)

	# セッションにログイン情報を持たせるよ
	session = CGI::Session.new(@cgi,{"new_session" => true})
	session['name'] = username
	sessionid = session.session_id()
	session.close
	
	@res.header['Set-cookie'] = "session_id = #{sessionid}"

	return session
	
end


# オーバーライド
##  "login.erb"を引数で与える形にすれば、このメソッドBase側に持ってこれるのでは？
def view_http_body()

	@res.body += render("login.erb", @context)

end


end



