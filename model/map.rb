#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../_util/SQL_master'
require_relative '../_util/SQL_transaction'
require_relative '../_util/cache'
require_relative './basemodel'


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
	num = calc_one_side(aisles)

	aisles = shape_aisles(aisles,num)
	side_aisles = aisles["side"]
	vertical_aisles = aisles["vertical"]

	rooms = create_rooms(side_aisles, vertical_aisles)
	
	map = Map.new(rooms)
	
	return map
end

# Graphutilで検証されたaislesのみ渡されるはずなので、
# ちゃんと自然数になることが保証されてる
def calc_one_side(aisles)
	return (Math.sqrt(1+2*aisles.count)/2).to_i
end


def shape_aisles(aisles, num)
	line=0
	result = {}

	(num-1).times do
		(num-1).times do 
			result["side"][line].push(aisles.shift.to_i)
		end
		num.times do
			result["vertical"][line].push(aisles.shift.to_i)
		end
		
		line+=1
		result["side"][line] = []
		result["vertical"][line] = []
	end

	(num-1).times do
		result["side"][line].push(aisles.shift.to_i)
	end
	
	if result["side"][line][num-2].nil? || !aisles.last.nil?
		raise
	end
	
	return result
end



def create_rooms(side_aisles, vertical_aisles)
	line = Float::INFINITY
	rooms = []
	
	vertical_aisles.each.with_index do |row1,index1|
		if row1.count(1) === 0
			line = index1+1
			break
		end
		
		rooms[y] = []
		row1.each.with_index do |row2,index2|
			if row2.to_i === 1
				x = index2
				y = index1
				
				rooms[y][x] = create_room(rooms,x,y)
				rooms[y+1][x] = create_room(rooms,x,y+1)
				
				add_aisle(rooms[y][x],aisle: DOWN)
				add_aisle(rooms[y+1][x],aisle: UP)
			end
		end
	end
	
	side_aisles.each.with_index do |row1,index1|
		if index1 === line
			break
		end
	
		rooms[y] = []
		row1.each.with_index do |row2, index2|
			if row2.to_i === 1
				x=index2
				y=index1
				
				rooms[y][x] = create_room(rooms,x,y)
				rooms[y][x+1] = create_room(rooms,x+1,y)
				
				add_aisle(rooms[y][x],aisle: RIGHT)
				add_aisle(rooms[y][x+1],aisle: LEFT)
			end
		end
	end
	
	return rooms
end

def create_room(rooms,x,y)
	if rooms.select{|room| room.x === x && room.y === y}.empty?
		return Map::Room.new(x,y)
	end
end

def add_aisle(room,aisle:)
	case aisle
	when UP
		aisle = "up"
	when LEFT
		aisle = "left"
	when DOWN
		aisle = "down"
	when RIGHT
		aisle = "right"
	end

	room.aisle[aisle] = true
end


def save(dangeon_id,floor)
	@rooms.each.with_index do |row1,index1|
		row1.each.with_index do |row2,index2|
			x = index2
			y = index1
		
			row2.shape_to_DBformat(x,y,dangeon_id,floor)
			row2.save()
		end
	end
end


def self.get(dangeon_id, floor)
	sql_master = SQL_master.instance.sql
	
	# todo memcached
	statement = sql_master.prepare("select * from master.maps where dangeon_id = ? and z = ?")
	result = statement.execute(dangeon_id,floor)
	
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

def shape_to_DBformat(x,y,dangeon_id,floor)
	@x = x
	@y = y
	@z = floor
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
		raise "aisleがおかしい"
	end
	
	@aisle = tmp_aisle
end

end

end

