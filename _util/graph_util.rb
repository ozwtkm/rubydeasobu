#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Graph
UP = 1
LEFT = 2
DOWN = 4
RIGHT = 8

def initialize(aisles,num)
	@side_aisles = []
	@vertical_aisles = []
	shape_aisles(aisles,num)

	@seq = 1.step
	@marks = []
	@nodeids = {}

	@nodes = {}
	@refs = []
	
	create_nodes_and_refs()
end
attr_accessor :nodes, :refs
	
	
#スマートなやり方あとで考える
def shape_aisles(aisles,num)
	line=0

	(num-1).times do
		(num-1).times do 
			@side_aisles[line].push(aisles.shift.to_i)
		end
		num.times do
			@vertical_aisles[line].push(aisles.shift.to_i)
		end
		
		line+=1
		@side_aisles[line] = []
		@vertical_aisles[line] = []
	end

	(num-1).times do
		@side_aisles[line].push(aisles.shift.to_i)
	end
	
	if @side_aisles[line][num-2].nil? || !aisles.last.nil?
		raise
	end
	
end



def create_nodes_and_refs()
	line = Float::INFINITY
	
	@vertical_aisles.each.with_index do |row1,index1|
		if row1.count(1) === 0
			line = index1+1
			break
		end

		row1.each.with_index do |row2,index2|
			x = index2
			y = index1
			
			if row2.to_i === 1
				create_node(x,y,aisle: DOWN)
				create_node(x,y+1,aisle: UP)
				
				add_ref(@nodeids[x.to_s + "_" + y.to_s], @nodeids[x.to_s + "_" + (y+1).to_s])
			end
		end
	end
	
	
	@side_aisles.each.with_index do |row1,index1|
		if index1 === line
			break
		end
	
		row1.each.with_index do |row2, index2|
			x=index2
			y=index1
		
			if row2.to_i === 1
				create_node(x,y,aisle: RIGHT)
				create_node(x+1,y,aisle: LEFT)
				
				@graph.add_ref(@nodeids[x.to_s + "_" + y.to_s], @nodeids[(x+1).to_s + "_" + y.to_s])
			end
		end
	end
end


def create_node(x,y,aisle: )
	if @nodeids[x.to_s + "_" + y.to_s].nil?
		nodeid = @graph.add_node(Node.new(x,y))
		@nodeids[x.to_s + "_" + y.to_s] = nodeid
	else
		nodeid = @nodeids[x.to_s + "_" + y.to_s]
	end

	@graph.get_node(nodeid).aisle += aisle
end


def add_node(obj)
	id = @seq.next

	@nodes[id] = obj

	return id
end




def add_ref(srcid,dstid)
	@refs << [srcid,dstid]
end



def get_node(id)
	return @nodes[id]
end



def validate()
	if @nodeids[0_0].nil?
		raise
	end

	mark_and_sweep(1)

	nodes = []
	@marks.each do |row|
		nodes << @nodes[row]
	end
	
	return nodes
end


# 直感的にはうまくいきそうと思うものの、不足なく周回でき、かつ終了できないみたいな状態に陥らない保障が取りきれてない
def mark_and_sweep(id)
	go = @refs.select {|a| a[0] === id}
	back = @refs.select {|a| a[1] === id}
	mark = @marks.select {|a| a === id}
	if mark.empty?
		@marks << id
	end
	
	if !go.empty? && @marks.select {|a| a === go[0][1]}.empty?
		nextid = go[0][1]
	elsif !go.empty? && !go[1].nil? && @marks.select {|a| a === go[1][1]}.empty?
		nextid = go[1][1]
	elsif !back.empty? 
		if !@marks.select {|a| a === back[0][0]}.empty? && !back[1].nil?
			nextid = back[1][0] #back[0][1]に戻らないと死ぬケースってあるか？
		else
			nextid = back[0][0]
		end
	else
		return #ここにくるのはスタート地点（[0,0]に戻ってきてかつ右も下もmark済のときのみ。）
	end

	mark_and_sweep(nextid)
end


class Node
	def initialize(x,y)
		@x=x
		@y=y
		@aisle=0
	end
	attr_accessor :aisle
	attr_reader :x, :y
end


end
