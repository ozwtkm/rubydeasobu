#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require_relative '../exception/Error_inconsistency_of_count'
require_relative '../exception/Error_inconsistency_of_aisle'

class Graph


def initialize(aisles)
	num = calc_one_side(aisles)

	@side_aisles = []
	@vertical_aisles = []
	shape_aisles(aisles,num)

	@relation = {} #mapにおけるroomとNodeの対応

	create_nodes()
end

def calc_one_side(aisles)
	num = (1+Math.sqrt(1+2*aisles.count))/2
	if num.ceil != num
		raise Error_inconsistency_of_count.new("通路")
	end
	
	return num.to_i
end
	

def shape_aisles(aisles,num)
	last_line = num-1

	(num-1).times do |index|
		@side_aisles[index] = []
		@vertical_aisles[index] = []
		(num-1).times do 
			@side_aisles[index].push(aisles.shift.to_i)
		end
		num.times do
			@vertical_aisles[index].push(aisles.shift.to_i)
		end
	end

	# n-1回のloopだと最下部のsideaislesだけ余るので例外対応
	@side_aisles[last_line] = []
	(num-1).times do
		@side_aisles[last_line].push(aisles.shift.to_i)
	end
	
end


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
	if @relation[x.to_s + "_" + y.to_s].nil?
		@relation[x.to_s + "_" + y.to_s] = Node.new
	end
	
	if vertical
		if @relation[x.to_s + "_" + (y+1).to_s].nil?
			@relation[x.to_s + "_" + (y+1).to_s] = Node.new
		end
	
		@relation[x.to_s + "_" + y.to_s].refs << @relation[x.to_s + "_" + (y+1).to_s]
		@relation[x.to_s + "_" + (y+1).to_s].refs << @relation[x.to_s + "_" + y.to_s]
	else
		if @relation[(x+1).to_s + "_" + y.to_s].nil?
			@relation[(x+1).to_s + "_" + y.to_s] = Node.new
		end
	
		@relation[x.to_s + "_" + y.to_s].refs << @relation[(x+1).to_s + "_" + y.to_s]
		@relation[(x+1).to_s + "_" + y.to_s].refs << @relation[x.to_s + "_" + y.to_s]
	end
end

def validate()
	# この制約は仕様の決めの問題なので別になくても良い
	if @relation["0_0"].nil?
		raise Error_inconsistency_of_aisle.new(start: true)
	end

	mark_and_sweep(@relation["0_0"])

	@relation.each do |k,v|
		if !v.is_marked
			raise Error_inconsistency_of_aisle.new()
		end
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
