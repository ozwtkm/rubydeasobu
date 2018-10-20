#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'mysql2'
require 'digest/sha1'
require 'securerandom'
require './baseclass'




class Regist < Base


def check_id_duplication(sql, username, passwd)

	# ユーザIDを重複チェック
	# DB側でunique制約しないとレースコンディションの可能性あり
	statement = sql.prepare("select COUNT(*) from users2 where name = ?")
	exist_count_tmp = statement.execute(username)
	
	exist_count = nil
	
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


# オーバーライド
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


# オーバーライド
def view_body()

	view_form()

end


end


# 各処理のためのインスタンス生成
cgi = CGI.new
sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')
regist = Regist.new

view_buffer = ""

# メイン処理
if cgi.request_method == "POST" then

	# 何はともあれまずは入力値検証
	regist.validate_special_character({:ユーザ名 => cgi["name"], :パスワード => cgi["passwd"]})

	username = cgi["name"]
	passwd = cgi["passwd"]
	
	# 登録処理。	
	if !regist.check_id_duplication(sql, username, passwd)
	
		view_buffer += "キャラ被りｗ"
		
	else 
	
		regist.regist(sql, username, passwd)
		view_buffer += CGI.escapeHTML(username) + "を登録しといたぞ。"
		
	end
			
else

	view_buffer += "このフォームから登録してね～～<br>"
	
end


regist.view()


