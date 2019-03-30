#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Monster
	attr_reader :monster_info

def initialize(monster_info, possession)

	@id = monster_info["id"]
	@name = monster_info["name"]
	@hp = monter_info["atk"]
	@def = monster_info["def"]
	@exp = monster_info["exp"]
	@money = monster_info["money"]
	@img_id = monster_info["img_id"]
	@rarity = monster_info["rarity"]
	@possession = possession

end


def self.get_monster(sql,user_id)

	statement = sql.prepare("select * from master.monsters")
	result = statement.execute()
	
	master_monster_list = []
	result.each do |row|
	
		master_monster_list << row
	
	end
	
	
	statement = sql.prepare("select monster_id from transaction.user_monster where user_id = ?")
	result = statement.execute(user_id)
	
	possession_monster_list = []
	result.each do |row|
	
		possession_monster_list << row["monster_id"]
	
	end
	
	user_monster_list = master_monster_list.select do |row|
	
		possession_monster_list.include?(row["monster_id"])
	
	end
	
	user_monster_list.each do |row|
	
		possession = possession_monster_list.count(row["id"])
		
		monsters << Monster.new(row, possession)
	
	end

	return monsters

end


def self.add_monster(sql, user_id, monster_id)

	statement = sql.prepare("insert into transaction.user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, monster_id)

end


end

