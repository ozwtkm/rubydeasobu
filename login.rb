#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'securerandom'
require 'cgi/session'

def view(input,view_buffer)

 print input.header({"charset" => "UTF-8",})

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

print view_buffer

end




input = CGI.new

sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')

view_buffer = ""

if  input.request_method == "POST" then

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
	
	statement = sql.prepare("select COUNT(*) from users2 where name = ? and passwd = ?")
	exist_count_tmp = statement.execute(username, pw_hash)
	exist_count_tmp.each do |row|
		row.each do |key,value|
			$exist_count = value
		end
	end

	# 2以上になることはない担保はDB側のカラム設計で
	## グローバル変数絶対殺す
	if $exist_count != 1 then 
	
		view_buffer += "出直して来いよな（訳：IDまたはパスワードがちがいます"
		
		$exist_count = nil
	
	else

		view_buffer +=  "ログインしたよ<br><br>"
		
		## ここセッションＩＤ更新したいがされない
		session = CGI::Session.new(input,{"new_session"=>true})
		session['name'] = username
		view_buffer += "ようこそ" + CGI.escapeHTML(session['name']) + "さん"
		
                session.close	        
	
		$exist_count = nil

               view_buffer += "<a href=sessiontest.rb>sessiontest</a>"

               view_buffer += session.to_s

	end
	
else

	view_buffer += "<br><br>GETだね"
	
end


view(input,view_buffer)
