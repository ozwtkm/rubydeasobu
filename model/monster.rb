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


end




