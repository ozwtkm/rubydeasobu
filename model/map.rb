#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'
require_relative '../exception/Error_inconsistency_of_aisle'
require_relative '../_util/graph_util'
require 'pp'

class Map < Base_model
UP = 1
LEFT = 2
DOWN = 4
RIGHT = 8

def initialize(rooms,dangeon_id,z)
	@rooms = rooms
	@dangeon_id = dangeon_id
	@z = z
end
attr_accessor :rooms
attr_reader :dangeon_id, :z

def self.create(aisles,dangeon_id,z)
	num = Graph.calc_one_side(aisles)
	shaped_aisles = Graph.shape_aisles(aisles,num)
	
	side_aisles = shaped_aisles["side"]
	vertical_aisles = shaped_aisles["vertical"]

	rooms = self.create_rooms(side_aisles, vertical_aisles, dangeon_id, z)
	map = Map.new(rooms, dangeon_id, z)

	validate_appearance_place(map)
	
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
				
				rooms[y][x] = Map::Room.new(x,y,z,dangeon_id) if rooms[y][x].nil?
				rooms[y+1][x] = Map::Room.new(x,y+1,z,dangeon_id) if rooms[y+1][x].nil?
				
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
				
				rooms[y][x] = Map::Room.new(x,y,z,dangeon_id) if rooms[y][x].nil?
				rooms[y][x+1] = Map::Room.new(x+1,y,z,dangeon_id) if rooms[y][x+1].nil?
				
				self.add_aisle(rooms[y][x],direction: RIGHT)
				self.add_aisle(rooms[y][x+1],direction: LEFT)
			end
		end
	end
	
	return rooms
end


def self.validate_appearance_place(map)
	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("select * from appearance_place where dangeon_id = ? and z = ?")
	result  = statement.execute(map.dangeon_id, map.z)

	Validator.validate_SQL_error(result.count, is_multi_line: true)

	result.each do |row|
		if map.rooms[row["y"]][row["x"]].nil?
			raise row["x"].to_s + "　" + row["y"].to_s + "は島になってないとだめ"
		end
	end
end

def self.add_aisle(room,direction:)
	room.aisle[direction] = true
end


def save()
	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("delete from maps where dangeon_id = ? and z = ?")
	statement.execute(@dangeon_id,@z)
	
	statement.close
	
	@rooms.each do |row1|
		row1.each do |row2|
			row2.save() if !row2.nil?
		end
	end
end


def self.get(dangeon_id, z)
	sql_master = SQL_master.instance.sql
	
	# todo memcached
	statement = sql_master.prepare("select * from maps where dangeon_id = ? and z = ?")
	result = statement.execute(dangeon_id,z)
	
	Validator.validate_SQL_error(result.count, is_multi_line: true)
	
	rooms = []
	result.each do |row|
		aisle_as_hash = Map::Room.convert_aisle_to_hash(row["aisle"])
		room = Map::Room.new(row["x"], row["y"], z, dangeon_id, aisle_as_hash)

		rooms[row["y"]] = [] if rooms[row["y"].to_i()].nil?
		rooms[row["y"]][row["x"]] = room
		
	end

	# roomsの形整え。もっと良くできる気がする
	rooms_with = rooms.map{|x| x.size()}.max()
	rooms.each do |row|
		if row[rooms_with-1].nil?
			row[rooms_with-1] = nil 
		end
	end

	statement.close()
	map = Map.new(rooms,dangeon_id,z)
	
	return map
end



class Room
attr_accessor :aisle
attr_reader :x, :y, :z


def initialize(x,y,z,dangeon_id,aisle={})
	@x = x
	@y = y
	@z = z
	@dangeon_id = dangeon_id
	@aisle = aisle
end

def save()
	aisle = convert_aisle_to_int()

	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("insert into maps(dangeon_id,x,y,z,aisle) values(?,?,?,?,?)")
	statement.execute(@dangeon_id,@x,@y,@z,aisle)
	
	statement.close
end

def convert_aisle_to_int()
	tmp = 0
	
	if @aisle[RIGHT]
		tmp += RIGHT
	end
	
	if @aisle[DOWN]
		tmp += DOWN
	end
	
	if @aisle[LEFT]
		tmp += LEFT
	end
	
	if @aisle[UP]
		tmp += UP
	end

	return tmp
end


def self.convert_aisle_to_hash(value)
	tmp_aisle = {}
	
	if value >= RIGHT
		tmp_aisle[RIGHT] = true
		value -= RIGHT
	end
	
	if value >= DOWN
		tmp_aisle[DOWN] = true
		value -= DOWN
	end
	
	if value >= LEFT
		tmp_aisle[LEFT] = true
		value -= LEFT
	end
	
	if value >= UP
		tmp_aisle[UP] = true
		value -= UP
	end
	
	if value != 0
		raise Error_inconsistency_of_aisle.new
	end
	
	return tmp_aisle
end

end

end

