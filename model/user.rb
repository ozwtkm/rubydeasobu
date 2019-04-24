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
	
	user = User.new(result.first)

	statement.close
	
	return user

end


def self.add_user(username, passwd)

	sql_transaction =  SQL_transaction.instance.sql

	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
		
	statement = sql_transaction.prepare("insert into transaction.users(name,salt,passwd) values(?,?,?)")
	statement.execute(username, salt, pw_hash)
	
	# add_userの直後にはinitialize_walletが控えているので、
	# どうしてもuser_idが欲しく、泣く泣く2度目のSQL発行。
	statement = sql_transaction.prepare("select id,name from transaction.users where name = ? limit 1")
	result = statement.execute(username)

	user = User.new(result.first)

	return user

end


end



