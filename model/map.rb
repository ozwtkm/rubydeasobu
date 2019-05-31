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
	@player_coord = [0,0] #todo初期位置処理（roomsのxy最小値で自動設定？
end


class Room
def initialize(right,left,up,down)
	@aisle["right"] = right
	@aisle["left"] = left
	@aisle["up"] = up
	@aisle["down"] = down
end
end
private_constant :Map_line


def self.get(dangeon_id, floor)
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("select * from master.maps where dangeon_id = ? and z = ?")
	statement.execute(dangeon_id,floor)
	
	rooms = []
	result.each do |row|
		aisle = convert_aisle(row.aisle) #aisleのbit列を人間がわかりやすい感じにする 
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
		self.add_room(row2["dangeon_id"],row2["x"],row2["y"],row2["z"],row2["aisle"])
	end
end
end

private

def self.add_room(dangeon_id,x,y,z,aisle)
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("insert into master.maps(dangeon_id,x,y,z,wall) values(?,?,?,?,?)")
	statement.execute(dangeon_id,x,y,z,wall)
	
	statement.close
end


end

