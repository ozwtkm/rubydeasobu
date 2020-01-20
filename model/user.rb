#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/sqltool'
require_relative '../exception/Error_duplicate_id'
require_relative './basemodel'
require_relative './monster'
require_relative './wallet'
require_relative './party'


class User < Base_model
	attr_reader :id, :name

def initialize(userinfo)
	@id = userinfo["id"]
	@name = userinfo["name"]
end


def self.get_user(user_id)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("select * from users where id = ? limit 1 for update")
	result = statement.execute(user_id)
	
	Validator.validate_SQL_error(result.count)
	
	user = User.new(result.first)

	statement.close
	
	return user
end



def self.add(username, passwd)
	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
	
	begin
		SQL.transaction("insert into users(name,salt,passwd) values(?,?,?)", [username, salt, pw_hash])
	rescue
		raise Error_duplicate_id.new
	end

	user_id = SQL_transaction.instance.sql.last_id

	user = User.new({"id"=>user_id, "name"=>username})

	Wallet.init(user_id)
	initial_monster = Monster.init(user_id)
	Party.init(user_id, initial_monster)

	SQL.close_statement

	user
end


end



