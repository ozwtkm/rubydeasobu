#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'
require_relative '../exception/Error_inconsistency_of_aisle'
require_relative '../_util/graph_util'

class Map < Base_model
UP = 1
LEFT = 2
DOWN = 4
RIGHT = 8

def initialize(rooms,dangeon_id,z)
	@rooms = rooms
	@dangeon_id = dangeon_id
	@z = z
	@player_coord = [0,0]
end
attr_accessor :player_coord,:rooms

def self.create(aisles,dangeon_id,z)
	num = Graph.calc_one_side(aisles)
	shaped_aisles = Graph.shape_aisles(aisles,num)
	
	side_aisles = shaped_aisles["side"]
	vertical_aisles = shaped_aisles["vertical"]

	rooms = self.create_rooms(side_aisles, vertical_aisles, dangeon_id, z)
	map = Map.new(rooms,dangeon_id,z)
	
	return map
end

def self.create_rooms(side_aisles, vertical_aisles, dangeon_id, z)
	rooms = []
	
	vertical_aisles.each.with_index do |row1,index1|
		rooms[index1] = [] if rooms[index1].nil?
		rooms[index1+1] = []

		
		row1.each.with_index do |row2,index2|
			if row2.to_i === 1
				x = index2
				y = index1
				
				rooms[y][x] = Map::Room.new(x,y,z,dangeon_id,aisle: {}) if rooms[y][x].nil?
				rooms[y+1][x] = Map::Room.new(x,y+1,z,dangeon_id,aisle: {}) if rooms[y+1][x].nil?
				
				self.add_aisle(rooms[y][x],direction: DOWN)
				self.add_aisle(rooms[y+1][x],direction: UP)
			end
		end
	end
	
	side_aisles.each.with_index do |row1,index1|
		rooms[index1] = [] if rooms[index1].nil?
	
		row1.each.with_index do |row2, index2|
			if row2.to_i === 1
				x=index2
				y=index1
				
				rooms[y][x] = Map::Room.new(x,y,z,dangeon_id,aisle: {}) if rooms[y][x].nil?
				rooms[y][x+1] = Map::Room.new(x+1,y,z,dangeon_id,aisle: {}) if rooms[y][x+1].nil?
				
				self.add_aisle(rooms[y][x],direction: RIGHT)
				self.add_aisle(rooms[y][x+1],direction: LEFT)
			end
		end
	end
	
	return rooms
end

def self.add_aisle(room,direction:)
	room.aisle[direction] = true
end


def save()
	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("delete from master.maps where dangeon_id = ? and z = ?")
	statement.execute(@dangeon_id,@z)
	
	statement.close
	
	@rooms.each.with_index do |row1,index1|
		row1.each.with_index do |row2,index2|
			x = index2
			y = index1
			
			row2.save() if !row2.nil?
		end
	end
end


def self.get(dangeon_id, z)
	sql_master = SQL_master.instance.sql
	
	# todo memcached
	statement = sql_master.prepare("select * from master.maps where dangeon_id = ? and z = ?")
	result = statement.execute(dangeon_id,z)
	
	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	rooms = []
	result.each do |row|
		room = Map::Room.new(row.x,row.y,z,dangeon_id,aisle: row.aisle)
		room.convert_aisle_to_hash()

		rooms[row["y"]] = [] if rooms[row["y"]].nil?
		rooms[row["y"]][row["x"]] = room
	end
	
	statement.close
	map = Map.new(rooms)
	
	return map
end



class Room
attr_accessor :aisle

def initialize(x,y,z,dangeon_id,aisle:)
	@x = x
	@y = y
	@z = z
	@dangeon_id = dangeon_id
	@aisle = aisle
end

def save()
	convert_aisle_to_int()

	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("insert into master.maps(dangeon_id,x,y,z,aisle) values(?,?,?,?,?)")
	statement.execute(@dangeon_id,@x,@y,@z,@aisle)
	
	statement.close
end

def convert_aisle_to_int()
	tmp_aisle = 0
	
	if @aisle[RIGHT]
		tmp_aisle += RIGHT
	end
	
	if @aisle[DOWN]
		tmp_aisle += DOWN
	end
	
	if @aisle[LEFT]
		tmp_aisle += LEFT
	end
	
	if @aisle[UP]
		tmp_aisle += UP
	end

	@aisle = tmp_aisle
end


def convert_aisle_to_hash()
	tmp_aisle = {}
	
	if @aisle >= RIGHT
		tmp_aisle[RIGHT] = true
		@aisle -= RIGHT
	end
	
	if @aisle >= DOWN
		tmp_aisle[DOWN] = true
		@aisle -= DOWN
	end
	
	if @aisle >= LEFT
		tmp_aisle[LEFT] = true
		@aisle -= LEFT
	end
	
	if @aisle >= UP
		tmp_aisle[UP] = true
		@aisle -= UP
	end
	
	if @aisle != 0
		raise Error_inconsistency_of_aisle.new
	end
	
	@aisle = tmp_aisle
end

end

end

