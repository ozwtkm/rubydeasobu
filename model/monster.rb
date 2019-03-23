#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Monster

def initialize(sql)

	@sql = sql

end


def get_monsters(user_id)

	statement = @sql.prepare("select * from master.monsters inner join transaction.user_monster on master.monsters.id = transaction.user_monster.monster_id where user_id = ?")
	result = statement.execute(user_id)

	monsters = []
	result.each do |row|
	
			monsters << row
	
	end

	return monsters

end


def get_monster_name(monster_id)

	statement = @sql.prepare("select name from master.monsters where id = ? limit 1")
	result = statement.execute(monster_id)

	monster_name = ""
	result.each do |row|
	
			monster_name = row
	
	end

	return monster_name["name"]

end


# かきとちゅう
def add_monster(user_id, monster_id)

	statement = @sql.prepare("insert into transaction.user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, monster_id)

end


end

