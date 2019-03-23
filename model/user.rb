#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class User

def initialize(sql)

	@sql = sql

end


def regist(username, passwd)

	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	statement = @sql.prepare("insert into transaction.users(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)

end


def get_userid(username)

	statement =@sql.prepare("select id from transaction.users where name = ?")
	result_tmp = statement.execute(username)

	result = nil
	result_tmp.each do |row|
	
		result = row["id"]
				
	end

	return result

end


end





