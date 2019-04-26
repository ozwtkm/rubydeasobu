#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_transaction'
require_relative '../exception/Error_duplicate_id'

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

	begin

		statement.execute(username, salt, pw_hash)

	rescue

		raise Error_duplicate_id.new
	
	end

	user = User.new({"id"=>sql_transaction.last_id,"name"=>username})

	statement.close
		
	return user

end


end



