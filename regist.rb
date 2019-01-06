#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'mysql2'
require 'cgi'
require 'digest/sha1'
require 'securerandom'
require_relative './baseclass'




class Regist < Base

RESULT_ID_DUPLICATE = RESULT_SPECIAL_CHARACTER_ERROR + 1
RESULT_SUCCESS = RESULT_SPECIAL_CHARACTER_ERROR + 2


def get_handler()

	view({:method => Base::METHOD_GET})
	
end


def post_handler()

	create_instance()	
	status = control()
	view(status)
	
end



def create_instance()
	
	@sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')
  
end



def control(view_status = {:method => "", :result => "", :username => "", :specialcharacter_list => ""})
		
		view_status[:method] = Base::METHOD_POST

		# 何はともあれまずは入力値検証
		begin
			
			validate_special_character({:ユーザ名 => @req.query["name"], :パスワード => @req.query["passwd"]})
			
		rescue => e
		
			view_status[:result] = Regist::RESULT_SPECIAL_CHARACTER_ERROR
			view_status[:specialcharacter_list] = e.falselist
			
			return view_status
			
		end

		# 登録処理。
		if !check_id_duplication(@req.query["name"], @req.query["passwd"])
		
			view_status[:result] = Regist::RESULT_ID_DUPLICATE
			
		else 
		
			regist(@req.query["name"], @req.query["passwd"])
			
			view_status[:result] = Regist::RESULT_SUCCESS
			view_status[:username] = @req.query["passwd"]

		end

	return view_status

end











def check_id_duplication(username, passwd)

	# ユーザIDを重複チェック
	# DB側でunique制約しないとレースコンディションの可能性あり
	statement = @sql.prepare("select COUNT(*) from users2 where name = ?")
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


def regist(username, passwd)

	# saltを生成
	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	# saltとパスワードを連結してハッシュ値生成
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	# ぶっこむ
	statement = @sql.prepare("insert into users2(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)

end



def view_form()

	@res.body += <<-EOS
<h1>会員登録するぞい</h1>
<form action="" method="post">
ユーザID<br>
<input type="text" name="name" value=""><br>
パスワード(text属性なのは茶目っ気)<br>
<input type="text" name="passwd" value=""><br>
<input type="submit" value="登録するぞい"><br>
</form>
EOS

end


# オーバーライド
def view_html_body(status={})

	view_form()
	
	case status[:method]
	when METHOD_GET then
		
	when METHOD_POST then

		case status[:result]
		when RESULT_SPECIAL_CHARACTER_ERROR then
		
			status[:specialcharacter_list].each do |row|
				@res.body += add_new_line("#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ")
			end
		
		when RESULT_ID_DUPLICATE then
		
			@res.body += add_new_line("キャラかぶってるで")
		
		when RESULT_SUCCESS then
	
			@res.body += add_new_line(CGI.escapeHTML(status[:username]) + "を登録しといたぞ")
	
		else
		
			@res.body += add_new_line("よくわからんけどうまくいかへんわ")
			
		end
	
	else
	
		@res.body += add_new_line("意味不明なメソッド")
	
	end
	
end


end
