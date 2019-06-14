#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../exception/Error_duplicate_id'
require_relative './basemodel'

class Admin_user < Base_model
	attr_reader :id, :name

def initialize(userinfo)
	@id = userinfo["id"]
	@name = userinfo["name"]
end

def self.get(user_id)
	sql_master =  SQL_master.instance.sql

	statement = sql_master.prepare("select * from master.admin_users where id = ? limit 1 for update")
	result = statement.execute(user_id)
	
	Validator.validate_SQL_error(result.count)
	
	user = User.new(result.first)

	statement.close
	
	return user
end


def self.add(username, passwd)
	sql_master =  SQL_master.instance.sql

	salt = SecureRandom.hex(10) + "aaaaburiburi"
		
	pw_hash = Digest::SHA1.hexdigest(passwd+salt)
	
	statement = sql_master.prepare("insert into master.users(name,salt,passwd) values(?,?,?)")

	begin
		statement.execute(username, salt, pw_hash)
	rescue
		raise Error_duplicate_id.new
	end

	user = User.new({"id"=>sql_master.last_id,"name"=>username})

	statement.close
		
	return user
end

end

