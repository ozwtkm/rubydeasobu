#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'securerandom'

print "Content-Type: text/html; charset=UTF-8\n\n"

sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')

print "<a href =matome.html>もどる</a><br><br>"

# ふぉーむ。
print <<EOM
<html>
<head>
        <meta http-equiv="Content-type" content="text/html; charset=UTF-8">
</head>
<body>
<h1>会員登録するぞい</h1>
<form action="" method="post">
	ユーザID<br>
	<input type="text" name="name" value=""><br>
	パスワード(text属性なのは茶目っ気)<br>
	<input type="text" name="passwd" value=""><br>
	<input type="submit" value="登録するぞい"><br>
</form>
</body>
</html>
EOM

input = CGI.new

if input.request_method == "POST" then

	# POSTされた値をinsertする。
	username = input["name"]
	passwd = input["passwd"]

	# ユーザIDを重複チェック
	# DB側でunique制約しないとレースコンディションの可能性あり
	statement = sql.prepare("select COUNT(*) from users2 where name = ?")
	exist_count_tmp = statement.execute(username)
	exist_count_tmp.each do |row|
		row.each do |key,value|
			$exist_count = value
		end
	end
	
	if $exist_count != 0 then
	
		print "キャラ被りｗ"
		
	else 
	
		# saltを生成
		salt = SecureRandom.hex(10) + "aaaaburiburi"
		
		# saltとパスワードを連結してハッシュ値生成
		pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
		# ぶっこむ
		statement = sql.prepare("insert into users2(name,salt,passwd) values(?,?,?)")
		statement.execute(username, salt, pw_hash)

		print "<h2>ユーザ一覧</h2>"
		
		res = sql.query("select * from users2")
		res.each do|row|
			p row
			p "<br>"
		end
		
	end

else

	p "GETだね"
	
end


