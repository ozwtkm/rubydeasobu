#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Monster
	attr_reader :monster_info

def initialize(monster_info)

	@monster_info = monster_info

end





# +----+-----------------+-------+-------+-------+-------+--------+--------+--------+------------+----------------+
# | id | name            | hp    | atk   | def   | exp   | money  | img_id | rarity | monster_id | count(user_id) |
# +----+-----------------+-------+-------+-------+-------+--------+--------+--------+------------+----------------+
# |  5 | XXXXX           |     2 |     1 |     2 |     0 |      3 |      1 | normal |          5 |             49 |
# | 10 | AAAAA           | 75442 | 84325 | 66431 | 64323 |  24124 |      4 | SSrare |         10 |              1 |
# | 11 | BBBBB           |  1000 |  1000 |  1000 |  1000 |   1000 |      3 | Srare  |         11 |              3 |
# | 12 | CCCCC           |   100 |   100 |   100 |   100 |    100 |      2 | rare   |         12 |             22 |
# | 13 | YYYYY           |     1 |     1 |     1 |     1 | 999999 |      5 | SSrare |       NULL |           NULL |
# +----+-----------------+-------+-------+-------+-------+--------+--------+--------+------------+----------------+
# ↓ こんな形式のデータセットをとってきてレコードごとにインスタンスつくる。

def self.get_monster(sql, user_id)

	statement = sql.prepare("select * from master.monsters left outer join (select monster_id, count(user_id) from transaction.user_monster where user_id = ? group by monster_id) as XXX on master.monsters.id = XXX.monster_id")
	result = statement.execute(user_id)
	
	monsterinfo = {}
	monsters = []
	result.each do |row|
	
			monsterinfo = row
		
			monsters << Monster.new(monsterinfo)
			
	end

	return monsters

end


def self.add_monster(sql, user_id, monster_id)

	statement = sql.prepare("insert into transaction.user_monster(user_id, monster_id) values(?,?)")
	statement.execute(user_id, monster_id)

end


end

