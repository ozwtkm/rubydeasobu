#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'


class Map < Base_model
	attr_reader :

def initialize(rooms)
	@rooms = rooms
	@player_coord = [0,0]
end


class Room
def initialize(right,left,up,down)
	@aisle["right"] = right
	@aisle["left"] = left
	@aisle["up"] = up
	@aisle["down"] = down
end

def self.add(dangeon_id,x,y,z,aisle)
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("insert into master.maps(dangeon_id,x,y,z,wall) values(?,?,?,?,?)")
	statement.execute(dangeon_id,x,y,z,wall)
	
	statement.close
end
end
private_constant :Room


def self.get(dangeon_id, floor)
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("select * from master.maps where dangeon_id = ? and z = ?")
	statement.execute(dangeon_id,floor)
	
	rooms = []
	result.each do |row|
		aisle = convert_aisle(row.aisle) #aisle‚Ìbit—ñ‚ðlŠÔ‚ª‚í‚©‚è‚â‚·‚¢Š´‚¶‚É‚·‚é 
		room = Map::Room.new(aisle["right"],aisle["left"],aisle["up"],aisle["down"])
		rooms[row.y.to_i][row.x.to_i] = room
	end
	
	statement.close
	
	map = Map.new(rooms)
	
	return map
end


def self.add_by_instance(map)
	map.each do |row1|
		row.each do |row2|
			Map::Room.add(row2["dangeon_id"],row2["x"],row2["y"],row2["z"],row2["aisle"])
		end
	end
end

end

