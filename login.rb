#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'cgi/session'
require_relative './baseclass'
	
class Login < Base


RESULT_LOGIN_FAILED = RESULT_SPECIAL_CHARACTER_ERROR + 1
RESULT_LOGIN_SUCCESS = RESULT_SPECIAL_CHARACTER_ERROR + 2


def get_handler()

	view({:method => Base::METHOD_GET})
	
end


def post_handler()

	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	@cgi = CGI.new
	status = control()
	view(status)
	
end


# 入力→viewの流れの核となる処理。
def control(view_status = {:method => "", :result => "", :username => "", :specialcharacter_list => ""})

	view_status[:method] = Base::METHOD_POST
	
	
	# 何はともあれまずは入力値検証
	begin

		validate_special_character({:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]})

	rescue => e

		view_status[:result] = Login::RESULT_SPECIAL_CHARACTER_ERROR
		view_status[:specialcharacter_list] = e.falselist

		return view_status

	end


	username = @req.query["name"]
	passwd = @req.query["passwd"]

	# ログインできる認証情報か？の検証
	begin
	
		check_ID_PW(username, passwd)
	
	rescue => e
		
			view_status[:result] = Login::RESULT_LOGIN_FAILED

			return view_status
		
	end
		
		
	session = login(username)

	view_status[:username] = session.instance_variable_get(:@data)["name"]
	view_status[:result] = Login::RESULT_LOGIN_SUCCESS
		
	return view_status

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
def view_http_body(status={})
	
	case status[:method]
	when METHOD_GET then
	
	when METHOD_POST then

		case status[:result]
		when RESULT_SPECIAL_CHARACTER_ERROR then
		
			status[:specialcharacter_list].each do |row|
			
				@context[:msg] = "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ"
			
			end
		
		when RESULT_LOGIN_FAILED then
			
			@context[:msg] = "IDかパスワードが違う"
		
		when RESULT_LOGIN_SUCCESS then
			
			@context[:msg] = CGI.escapeHTML(status[:username]) + "でログインしたった"
	
		else
		
			@context[:msg] = "よくわからんけどうまくいかへんわ"
			
		end
	
	else
	
		@context[:msg] = "意味不明なメソッド"
	
	end

	@res.body += Base.render("login.erb", @context)

end


end



