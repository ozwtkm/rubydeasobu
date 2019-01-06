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

	create_instance()	
	status = control()
	view(status)
	
end

# オーバーライド
def create_instance()

	ARGV.replace(["abc=001&def=002"]) # オフラインモード回避。
	
	@cgi = CGI.new
	@sql = Mysql2::Client.new(:socket => '/var/lib/mysql/mysql.sock', :host => 'localhost', :username => 'testwebrick', :password => 'test', :encoding => 'utf8', :database => 'webrick_test')
  
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

			# 2以上になることはない担保はDB側のカラム設計でやるよ
			if check_ID_PW(username, passwd) != 1 then
		
				view_status[:result] = Login::RESULT_LOGIN_FAILED
			
			else

				session = login(username)

				view_status[:username] = session.instance_variable_get(:@data)["name"]
				view_status[:result] = Login::RESULT_LOGIN_SUCCESS
			
			end

	return view_status

end






def check_ID_PW(username, passwd)
	
	#ログイン可能な入力組み合わせかチェックする。（入力値組に合致するレコードの個数を返す）
	
	statement = @sql.prepare("select salt from users2 where name = ?")
	salt_tmp = statement.execute(username)
	
	salt = nil
	salt_tmp.each do |row|
		row.each do |key,value|
			salt = value
		end
	end
	
	# ユーザIDからsaltが取れなかった場合、hexdigest(passwd + salt)でこけてエラーになるので回避線を設定
	pw_hash = nil
	if salt != nil then
		pw_hash = Digest::SHA1.hexdigest(passwd + salt)
	end
	
	statement = @sql.prepare("select COUNT(*) from users2 where name = ? and passwd = ?")
    exist_count_tmp = statement.execute(username, pw_hash)
	
	exist_count = nil
	exist_count_tmp.each do |row|
		row.each do |key,value|
			exist_count = value
		end
	end

	return exist_count

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
def view_html_body(status={})

	view_form()
	
	case status[:method]
	when METHOD_GET then
	
	when METHOD_POST then

		case status[:result]
		when RESULT_SPECIAL_CHARACTER_ERROR then
		
			status[:specialcharacter_list].each do |row|
				@res.body += "#{row}は/\A[a-zA-Z0-9_@]+\z/でよろ"
			end
		
		when RESULT_LOGIN_FAILED then
			
			@res.body += "IDかパスワードが違う"
		
		when RESULT_LOGIN_SUCCESS then
			
			@res.body += CGI.escapeHTML(status[:username]) + "でログインしたった"
	
		else
		
			@res.body += "よくわからんけどうまくいかへんわ"
			
		end
	
	else
	
		@res.body += "意味不明なメソッド"
	
	end

	add_new_line()

end




def view_form()

	@res.body += <<-EOS
<h1>ログインするぞい</h1>
<form action="" method="post">
ユーザID<br>
<input type="text" name="name" value=""><br>
パスワード(text属性なのは茶目っ気)<br>
<input type="text" name="passwd" value=""><br>
<input type="submit" value="ログインするぞい"><br>
</form>
	EOS

end


end



