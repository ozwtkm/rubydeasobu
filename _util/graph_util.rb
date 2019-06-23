#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../exception/Error_inconsistency_of_count'
require_relative '../exception/Error_inconsistency_of_aisle'

class Graph

def initialize(aisles)
	num = Graph.calc_one_side(aisles)
	shaped_aisles = Graph.shape_aisles(aisles,num)

	@side_aisles = shaped_aisles["side"]
	@vertical_aisles = shaped_aisles["vertical"]
	
	@relation = {} #mapにおけるroomとNodeの対応
	
	create_nodes()

	validate()
end


def self.calc_one_side(aisles)
	num = (1+Math.sqrt(1+2*aisles.count))/2
	if num.ceil != num
		raise Error_inconsistency_of_count.new("通路")
	end
	
	return num.to_i
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

	# n-1回のloopだと最下部のsideaislesだけ余るので例外対応
	result["side"][last_line] = []
	(num-1).times do
		result["side"][last_line].push(aisles.shift.to_i)
	end

	return result
end


# もうちょっと綺麗に書ける余地あり
def create_nodes()
	@vertical_aisles.each.with_index do |row1,index1|
		row1.each.with_index do |row2,index2|
			if row2.to_i === 1
				x = index2
				y = index1
				handle_aisle(x,y,vertical: true)
			end
		end
	end
	
	
	@side_aisles.each.with_index do |row1,index1|
		row1.each.with_index do |row2, index2|
			if row2.to_i === 1
				x=index2
				y=index1
				handle_aisle(x,y,vertical: false)
			end
		end
	end
end

def handle_aisle(x,y,vertical: )
	if @relation[coord(x,y)].nil?
		@relation[coord(x,y)] = Node.new
	end
	
	if vertical
		if @relation[coord(x,y+1)].nil?
			@relation[coord(x,y+1)] = Node.new
		end
	
		@relation[coord(x,y)].refs << @relation[coord(x,y+1)]
		@relation[coord(x,y+1)].refs << @relation[coord(x,y)]
	else
		if @relation[coord(x+1,y)].nil?
			@relation[coord(x+1,y)] = Node.new
		end
	
		@relation[coord(x,y)].refs << @relation[coord(x+1,y)]
		@relation[coord(x+1,y)].refs << @relation[coord(x,y)]
	end
end

def coord(x,y)
	return x.to_s + "_" + y.to_s
end


def validate()
	# この制約は仕様の決めの問題なので別になくても良い
	if @relation[coord(0,0)].nil?
		raise Error_inconsistency_of_aisle.new(invalid_start: true)
	end

	mark_and_sweep(@relation[coord(0,0)])
	
	if @relation.any?{|x| x === false}
		raise Error_inconsistency_of_aisle.new()
	end
end


def mark_and_sweep(current)
	if !current.is_marked
		current.is_marked = true
	end

	current.refs.each do |row|
		if !row.is_marked
			mark_and_sweep(row)
		end
	end
end


class Node
	def initialize()
		@is_marked = false
		@refs = []
	end
	
	attr_reader :refs
	attr_accessor :is_marked
end


end
