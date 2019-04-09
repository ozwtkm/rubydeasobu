#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'

class Monster
	attr_reader :id, :name, :hp, :def, :exp, :money, :img_id, :rarity

def initialize(monster_info)

	@id = monster_info["id"]
	@name = monster_info["name"]
	@hp = monster_info["atk"]
	@def = monster_info["def"]
	@exp = monster_info["exp"]
	@money = monster_info["money"]
	@img_id = monster_info["img_id"]
	@rarity = monster_info["rarity"]

end

#あとで消す
def self.get_master_monsters()

	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("select * from master.monsters")
	result = statement.execute()
	
	master_monster_list = {}
	result.each do |row|
	
		master_monster_list[row["id"]] = Monster.new(row)
	
	end

	statement.close
	
	return master_monster_list

end


def self.get_possession_monsters(user_id)

	sql_transaction =  SQL_transaction.instance.sql
	
	master_monster_list = Monster.get_master_monsters()
	
	statement = sql_transaction.prepare("select monster_id from transaction.user_monster where user_id = ?")
	result = statement.execute(user_id)
	
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


end

