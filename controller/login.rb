#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'digest/sha1'
require 'cgi/session'
require_relative './baseclass'


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
	
		check_ID_PW(username, passwd)
	
	rescue => e
		
		@context[:msg] << "IDかパスワードが違う"

		return
		
	end
		
		
	sessionid = login(username)
	
	@res.header['Set-cookie'] = "session_id=" + sessionid
	
	@context[:msg] << username + "でログインしたった"


end


def check_ID_PW(username, passwd)
	
	statement = @sql.prepare("select salt from users2 where name = ? limit 1")
	result_tmp = statement.execute(username)
	
	if result_tmp.count == 0
	
		raise
	
	end
	
 	result = result_tmp.first
 	
	pw_hash = Digest::SHA1.hexdigest(passwd + result["salt"])
	
	statement = @sql.prepare("select * from users2 where name = ? and passwd = ? limit 1")
	result = statement.execute(username, pw_hash)
	
	if result.count == 0
	
		raise
	
	end
	
end


def login(username)

	# セッションにログイン情報を持たせるよ
	session = CGI::Session.new(@cgi,{"new_session" => true})
	session['name'] = username
	sessionid = session.session_id()
	session.close
	
	return sessionid
	
end


end
