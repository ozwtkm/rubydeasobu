#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/serializer'
require_relative '../_util/cache'
require_relative './basemodel'
require_relative '../exception/Error_shortage_of_material'

class Monster < Base_model
	attr_reader :id, :name, :hp, :atk, :def, :exp, :money, :img_id, :rarity

def initialize(monster_info)
	@id = monster_info["id"]
	@name = monster_info["name"]
	@hp = monster_info["hp"]
	@atk = monster_info["atk"]
	@def = monster_info["def"]
	@exp = monster_info["exp"]
	@money = monster_info["money"]
	@img_id = monster_info["img_id"]
	@rarity = monster_info["rarity"]
end

def self.get_master_monsters()
	master_monster_list = Cache.instance.get('master_monster_list')

	if !master_monster_list.nil?
		Log.log("cacheありなのでキャッシュから取得した")	
		return master_monster_list
	end
	
	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("select * from master.monsters")
	result = statement.execute()

	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	master_monster_list = {}
	result.each do |row|
		master_monster_list[row["id"]] = Monster.new(row)
	end

	statement.close
	
	Cache.instance.set('master_monster_list',master_monster_list)

	Log.log("cacheなしなのでセットした")
	return master_monster_list
	
end


def self.get_possession_monsters(user_id, limit=10, offset=0)
	sql_transaction =  SQL_transaction.instance.sql
	
	master_monster_list = Monster.get_master_monsters()
	
	statement = sql_transaction.prepare("select monster_id from transaction.user_monster where user_id = ? limit ? offset ?")
	result = statement.execute(user_id, limit, offset)
	
	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	possession_monster_list = []
	result.each do |row|
		possession_monster_list << master_monster_list[row["monster_id"]].clone
	end
	
	statement.close

	return possession_monster_list
end

def self.add_monster(user_id, monster_id)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("insert into transaction.user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, monster_id)
	statement.close
end

def self.delete_monster(user_id, monster_id, count)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("delete from transaction.user_monster where user_id = ? and monster_id = ? limit ?")
	statement.execute(user_id, monster_id, count)

	if sql_transaction.affected_rows != count
		raise Error_shortage_of_material.new
	end

	statement.close
end


end

