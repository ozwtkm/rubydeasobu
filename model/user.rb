#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_transaction'

class User
	attr_reader :id, :name

def initialize(userinfo)

	@id = userinfo["id"]
	@name = userinfo["name"]

end



def self.get_user(username)

	sql_transaction =  SQL_transaction.instance.sql

	userinfo = {}

	statement = sql_transaction.prepare("select * from transaction.users where name = ? limit 1")
	result = statement.execute(username)
	statement.close
	
	result.each do |row|
	
		userinfo = row
	
	end
	
	user = User.new(userinfo)
	
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


def get_userid(username)

	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("select id from transaction.users where name = ? limit 1")
	result_tmp = statement.execute(username)
	statement.close

	result = nil
	result_tmp.each do |row|
	
		result = row["id"]
				
	end

	return result

end


end



