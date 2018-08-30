#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'securerandom'
require 'cgi/session'

input = CGI.new
session = CGI::Session.new(input)
print input.header({"charset" => "UTF-8",})

sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')

print "<a href =matome.html>もどる</a><br><br>"

# ふぉーむ。
print <<EOM
<html>
<head>
        <meta http-equiv="Content-type" content="text/html; charset=UTF-8">
</head>
<body>
<h1>ログインするぞい</h1>
<form action="" method="post">
	ユーザID<br>
	<input type="text" name="name" value=""><br>
	パスワード(text属性なのは茶目っ気)<br>
	<input type="text" name="passwd" value=""><br>
	<input type="submit" value="ログイン"><br>
</form>
</body>
</html>
EOM

if input.request_method == "POST" then

	username = input["name"]
	passwd = input["passwd"]

	# ログイン可能かチェック
	
	statement = statement = sql.prepare("select salt from users2 where name = ?")
	salt_tmp = statement.execute(username)
	salt_tmp.each do |row|
		row.each do |key,value|
			$salt = value
		end
	end
	
	pw_hash = Digest::SHA1.hexdigest(passwd+$salt)
	p pw_hash
	
	statement = sql.prepare("select COUNT(*) from users2 where name = ? and passwd = ?")
	exist_count_tmp = statement.execute(username, pw_hash)
	exist_count_tmp.each do |row|
		row.each do |key,value|
			$exist_count = value
		end
	end

	# 2以上になることはない担保はDB側のカラム設計で
	if $exist_count != 1 then 
	
		print "出直して来いよな（訳：IDまたはパスワードがちがいます"
	
	else

		print "ログインしたよ<br><br>"
		
		## ここセッションＩＤ更新したいがされない
		session = CGI::Session.new(input,{"new_session"=>true})
		session['name'] = username
		## stored XSS
		print "ようこそ" + session['name'] + "さん"
	
	end
	
else

	print "<br><br>GETだね"
	
end


