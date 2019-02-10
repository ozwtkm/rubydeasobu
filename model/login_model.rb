#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'cgi'
require 'digest/sha1'
require 'cgi/session'

class Login_model


def check_ID_PW(sql, username, passwd)
	
	statement = sql.prepare("select salt from users2 where name = ? limit 1")
	result_tmp = statement.execute(username)
		
	result = nil
	result_tmp.each do |row|
		result = row
	end
	
	if result.nil?
	
		raise
	
	end
	
	pw_hash = Digest::SHA1.hexdigest(passwd + result["salt"])
	
	statement = sql.prepare("select * from users2 where name = ? and passwd = ? limit 1")
	result = statement.execute(username, pw_hash).count
	
	if result == 0
	
		raise
	
	end

end


def login(cgi, username)

	# セッションにログイン情報を持たせるよ
	session = CGI::Session.new(cgi,{"new_session" => true})
	session['name'] = username
	session.close
	
	return session
	
end


end


