#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'securerandom'


class Base

def view_header()

	print <<EOM
	    Content-Type: text/html; charset=UTF-8\r\n\r\n
		<html>
		<head>
		<meta http-equiv="Content-type" content="text/html; charset=UTF-8">
		</head>
		<body>
EOM
		
end


def view_footer()
	
	print "<a href =matome.html>もどる</a><br><br>"
	print "</body>"
	
end


def view_form()

	print <<EOM
		<h1>会員登録するぞい</h1>
		<form action="" method="post">
		ユーザID<br>
		<input type="text" name="name" value=""><br>
		パスワード(text属性なのは茶目っ気)<br>
		<input type="text" name="passwd" value=""><br>
		<input type="submit" value="登録するぞい"><br>
		</form>

EOM

end


def view_body(view_buffer)

	print view_buffer

end


def validate_special_character(input)

		if input.match(/[0-9a-zA-Z_@-]*/) == nil
	
			return false
		
		else
	
			return true
	
		end
	
end


end




class Regist < Base


def check_id_duplication(sql, username, passwd)

	# ユーザIDを重複チェック
	# DB側でunique制約しないとレースコンディションの可能性あり
	statement = sql.prepare("select COUNT(*) from users2 where name = ?")
	exist_count_tmp = statement.execute(username)
	exist_count_tmp.each do |row|
		row.each do |key,value|
			exist_count = value
		end
	end
	
	if exist_count != 0 then
		
		return false
	
	else
	
		return true
	
	end

end


def regist(sql, username, passwd)

	# saltを生成
	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	# saltとパスワードを連結してハッシュ値生成
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	# ぶっこむ
	statement = sql.prepare("insert into users2(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)

end


end


# 各処理のためのインスタンス生成
cgi = CGI.new
sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')
regist = Regist.new

view_buffer = ""

# メイン処理
if cgi.request_method == "POST" then

	# POSTされた値をinsertする。
	username = cgi["name"]
	passwd = cgi["passwd"]

	# 入力値がすべてvalidate_special_characterをtrueとしたときのみ登録処理に進みたい。
	# なんかここ気に食わない
	validate_result = true
	[username,passwd].each do |row|
		if !regist.validate_special_character(row) then
			view_buffer += "#{row}に特殊文字入れるな<br>"
			validate_result　= false
		end
	end
	
	
	# 登録処理。
	if validate_result then 
		if !regist.check_id_duplication(sql, username, passwd)
	
			view_buffer += "キャラ被りｗ"
		
		else 
	
			regist.regist(sql, username, passwd)
			view_buffer += "#{username}を登録しといたぞ。"
		
		end
	end
			
else

	view_buffer += "このフォームから登録してね～～"
	
end


regist.view_header()
regist.view_form()
regist.view_body(view_buffer)
regist.view_footer()

