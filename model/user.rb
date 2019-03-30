#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class User
	attr_reader :userinfo

def initialize(userinfo)

	@id = userinfo["id"]
	@name = userinfo["name"]

end



def self.get_user(username, sql)

	userinfo = {}

	statement = sql.prepare("select * from transaction.users where name = ?")
	result = statement.execute(username)
	
	result.each do |row|
	
		userinfo = row
	
	end
	
	user = User.new(userinfo)
	
	return user

end


def self.regist(sql, username, passwd)

	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	statement = sql.prepare("insert into transaction.users(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)

end


def get_userid(sql, username)

	statement =sql.prepare("select id from transaction.users where name = ?")
	result_tmp = statement.execute(username)

	result = nil
	result_tmp.each do |row|
	
		result = row["id"]
				
	end

	return result

end


end





