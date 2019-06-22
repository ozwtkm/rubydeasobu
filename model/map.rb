#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'
require_relative '../exception/Error_inconsistency_of_aisle'


class Map < Base_model
UP = 1
LEFT = 2
DOWN = 4
RIGHT = 8

def initialize(rooms)
	@rooms = rooms
	@player_coord = [0,0]
end
attr_reader :rooms
attr_accessor :player_coord


def self.create(aisles)
	num = self.calc_one_side(aisles)

	shaped_aisles = self.shape_aisles(aisles,num)
	side_aisles = shaped_aisles["side"]
	vertical_aisles = shaped_aisles["vertical"]

	rooms = self.create_rooms(side_aisles, vertical_aisles)
	
	map = Map.new(rooms)
	
	return map
end

# Graphutilで検証されたaislesのみ渡されるはずなので、
# ちゃんと自然数になることが保証されてる
def self.calc_one_side(aisles)
	return ((1+Math.sqrt(1+2*aisles.count))/2).to_i
end


def self.shape_aisles(aisles, num)
	last_line = num-1
	result = {}
	result["side"] = []
	result["vertical"] = []

	(num-1).times do |index|
		result["side"][index] = []
		result["vertical"][index] = []
		
		(num-1).times do 
			result["side"][index].push(aisles.shift.to_i)
		end
		
		num.times do
			result["vertical"][index].push(aisles.shift.to_i)
		end
	end

	result["side"][last_line] = []
	(num-1).times do
		result["side"][last_line].push(aisles.shift.to_i)
	end

	return result
end



def self.create_rooms(side_aisles, vertical_aisles)
	rooms = []
	
	vertical_aisles.each.with_index do |row1,index1|
		rooms[index1] = [] if rooms[index1].nil?
		rooms[index1+1] = []

		
		row1.each.with_index do |row2,index2|
			if row2.to_i === 1
				x = index2
				y = index1
				
				rooms[y][x] = self.create_room(rooms,x,y)
				rooms[y+1][x] = self.create_room(rooms,x,y+1)
				
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
				
				rooms[y][x] = self.create_room(rooms,x,y)
				rooms[y][x+1] = self.create_room(rooms,x+1,y)
				
				self.add_aisle(rooms[y][x],direction: RIGHT)
				self.add_aisle(rooms[y][x+1],direction: LEFT)
			end
		end
	end
	
	return rooms
end

def self.create_room(rooms,x,y)
	if rooms[y][x].nil?
		return Map::Room.new()
	end
	
	return rooms[y][x]
end


def self.add_aisle(room,direction:)
	case direction
	when UP
		direction = "up"
	when LEFT
		direction = "left"
	when DOWN
		direction = "down"
	when RIGHT
		direction = "right"
	end

	room.aisle[direction] = true
end


def save(dangeon_id,z)
	# ON DUPLICATE KEY UPDATE方式だと、現状のmapの仕様では、
	# update時、newされてない座標の既存の部屋が残存してしまうため、sava時は一回deleteすることにする
	sql_master = SQL_master.instance.sql

	statement = sql_master.prepare("delete from master.maps where dangeon_id = ? and z = ?")
	statement.execute(dangeon_id,z)
	
	statement.close

	@rooms.each.with_index do |row1,index1|
		row1.each.with_index do |row2,index2|
			x = index2
			y = index1
		
			row2.shape_to_DBformat(x,y,dangeon_id,z)
			row2.save()
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
		room = Map::Room.new()
		room.aisle = row.aisle
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

def initialize()
	@aisle = {}
	@aisle["right"] = nil
	@aisle["left"] = nil
	@aisle["up"] = nil
	@aisle["down"] = nil
end

def save()
	sql_master = SQL_master.instance.sql
	
	statement = sql_master.prepare("insert into master.maps(dangeon_id,x,y,z,aisle) values(?,?,?,?,?) ON DUPLICATE KEY UPDATE dangeon_id=?,x=?,y=?,z=?,aisle=?")
	statement.execute(@dangeon_id,@x,@y,@z,@aisle,@dangeon_id,@x,@y,@z,@aisle)
	
	statement.close
end

def shape_to_DBformat(x,y,dangeon_id,z)
	@x = x
	@y = y
	@z = z
	@dangeon_id = dangeon_id
	
	convert_aisle_to_int()
end

def convert_aisle_to_int()
	tmp_aisle = 0
	
	if @aisle["right"]
		tmp_aisle += RIGHT
	end
	
	if @aisle["down"]
		tmp_aisle += DOWN
	end
	
	if @aisle["left"]
		tmp_aisle += LEFT
	end
	
	if @aisle["up"]
		tmp_aisle += UP
	end

	@aisle = tmp_aisle
end


def convert_aisle_to_hash()
	tmp_aisle = {}
	
	if @aisle >= RIGHT
		tmp_aisle["right"] = true
		@aisle -= RIGHT
	end
	
	if @aisle >= DOWN
		tmp_aisle["down"] = true
		@aisle -= DOWN
	end
	
	if @aisle >= LEFT
		tmp_aisle["left"] = true
		@aisle -= LEFT
	end
	
	if @aisle >= UP
		tmp_aisle["up"] = true
		@aisle -= UP
	end
	
	if @aisle != 0
		raise Error_inconsistency_of_aisle.new
	end
	
	@aisle = tmp_aisle
end

end

end

