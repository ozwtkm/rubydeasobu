#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_transaction'

class User
	attr_reader :id, :name

def initialize(userinfo)

	@id = userinfo["id"]
	@name = userinfo["name"]

end


def self.get_user(user_id)

	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("select * from transaction.users where id = ? limit 1")
	result = statement.execute(user_id)
	
	userinfo = {}
	result.each do |row|
	
		userinfo = row
	
	end
	
	user = User.new(userinfo)
	
	statement.close
	
	return user

end


def self.regist(username, passwd)

	sql_transaction =  SQL_transaction.instance.sql

	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	statement = sql_transaction.prepare("insert into transaction.users(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)
	statement.close

end


end



