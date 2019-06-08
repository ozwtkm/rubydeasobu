#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'


class Map < Base_model

def initialize(rooms)
	@rooms = rooms
	@player_coord = [0,0]
end
attr_reader :rooms
attr_accessor :player_coord


def save_by_instance(map,dangeon_id,floor)
	map.each do |row|
		Map::Room.save(dangeon_id,row.x,row.y,floor,row.aisle)
	end
end




def self.get(dangeon_id, floor)
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("select * from master.maps where dangeon_id = ? and z = ?")
	result = statement.execute(dangeon_id,floor)
	
	rooms = [[]]
	result.each do |row|
		aisle = self.convert_aisle(row["aisle"]) #aisleのbit列を人間がわかりやすい感じにする 
		room = Map::Room.new(aisle["right"],aisle["left"],aisle["up"],aisle["down"])

		rooms[row["y"]] = []
		rooms[row["y"]][row["x"]] = room
	end
	
	statement.close
	map = Map.new(rooms)
	
	return map
end



class Room
def initialize(right,left,up,down)
	@aisle = {}
	@aisle["right"] = right
	@aisle["left"] = left
	@aisle["up"] = up
	@aisle["down"] = down
end

def self.save(dangeon_id,x,y,z,aisle)
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("insert into master.maps(dangeon_id,x,y,z,aisle) values(?,?,?,?,?) ON DUPLICATE KEY UPDATE dangeon_id=?,x=?,y=?,z=?,aisle=?")
	statement.execute(dangeon_id,x,y,z,aisle,dangeon_id,x,y,z,aisle)
	
	statement.close
end
end






private

# 上から反時計回りに1248が割り当てられてる
def self.convert_aisle(num)
	aisle = {}
	
	if num >= 8
		aisle["right"] = true
		num -= 8
	end
	
	if num >= 4
		aisle["down"] = true
		num -= 4
	end
	
	if num >= 2
		aisle["left"] = true
		num -= 2
	end
	
	if num >= 1
		aisle["up"] = true
		num -= 1
	end
	
	if num != 0
		raise "aisleがおかしい"
	end
	
	return aisle
end

end

