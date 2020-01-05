#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/serializer'
require_relative '../_util/cache'
require_relative './basemodel'
require_relative '../exception/Error_shortage_of_material'

class Monster < Base_model
	INITIAL_MONSTER_ID = 5

	attr_reader :id, :name, :hp, :mp, :speed, :atk, :def, :exp, :money, :img_id, :rarity

def initialize(monster_info)
	@id = monster_info["id"]
	@name = monster_info["name"]
	@hp = monster_info["hp"]
	@mp = monster_info["mp"]
	@speed = monster_info["speed"]
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

	statement = sql_master.prepare("select * from monsters")
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


def self.get_possession_monsters(user_id, limit:10, offset:0)
	sql_transaction =  SQL_transaction.instance.sql
	
	master_monster_list = Monster.get_master_monsters()
	
	statement = sql_transaction.prepare("select id, monster_id from user_monster where user_id = ? limit ? offset ?")
	result = statement.execute(user_id, limit, offset)
	
	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	possession_monster_list = {}
	result.each do |row|
		possession_monster_list[row["id"]] = master_monster_list[row["monster_id"]].clone
	end
	
	statement.close

	return possession_monster_list
end


def self.get_specific_monster(id)
	master_monster_list = Monster.get_master_monsters()

	monster = master_monster_list[id]

	if monster.nil?
		raise "id#{id}からモンスター取ってこれない"
	end

	return monster
end

def self.add_monster(user_id, monster_id)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("insert into user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, monster_id)
	statement.close
end

def self.delete_monster(user_id, monster_id, count)
	sql_transaction =  SQL_transaction.instance.sql

	begin
		statement = sql_transaction.prepare("delete from user_monster where user_id = ? and monster_id = ? limit ?")
		statement.execute(user_id, monster_id, count)
	rescue
		raise Error_shortage_of_material.new #party選択に含めてるモンスターを素材にしようとした時ここで怒る
	end

	if sql_transaction.affected_rows != count
		raise Error_shortage_of_material.new
	end

	statement.close
end

# ユーザ登録時だけ呼ばれる
def self.init(user_id)
	sql_transaction =  SQL_transaction.instance.sql

	statement = sql_transaction.prepare("insert into user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, 	INITIAL_MONSTER_ID)
	possession_monster_id = statement.last_id()

	statement.close

	return possession_monster_id
end

end

