#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Monster

def initialize(monsters)

	@monsters = monsters

end


def self.get_monster(sql)

	statement = sql.prepare("select * from master.monsters")
	result = statement.execute()

	monsters = []
	result.each do |row|
	
			monsters << row
	
	end

	monster = Monster.new(sql, monsters)

	return monster

end


def self.add_monster(user_id, monster_id)

	statement = sql.prepare("insert into transaction.user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, monster_id)

end


end

