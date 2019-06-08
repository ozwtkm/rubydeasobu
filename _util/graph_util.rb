#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Graph

def initialize(aisles,num)
	@side_aisles = []
	@vertical_aisles = []
	shape_aisles(aisles,num)

	@seq = 1.step

	@nodeids = {}
	@nodes = []
	@marks = []
	
	create_nodes()
end
	
	
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



def create_nodes()
	line = Float::INFINITY
	
	@vertical_aisles.each.with_index do |row1,index1|
		if row1.count(1) === 0
			line = index1+1
			break
		end

		row1.each.with_index do |row2,index2|
			if row2.to_i === 1
				x = index2
				y = index1
				handle_aisle(x,y,vertical: true)
			end
		end
	end
	
	
	@side_aisles.each.with_index do |row1,index1|
		if index1 === line
			break
		end

		row1.each.with_index do |row2, index2|
			if row2.to_i === 1
				x=index2
				y=index1
				handle_aisle(x,y,side: true)
			end
		end
	end
end


def handle_aisle(x,y,vertical: false,side: false)
	current_id = @nodeids[x.to_s + "_" + y.to_s]
	if current_id.nil?
		current = add_node(Graph::Node.new())
	else
		current = get_node(current_id)
	end

	if vertical
		go_id = @nodeids[x.to_s + "_" + (y+1).to_s]
	end

	if side
		go_id = @nodeids[(x+1).to_s + "_" + y.to_s]
	end
	
	go = get_node(go_id)
	go.back << current.id
	current.go << go_id
end


def add_node()
	id = @seq.next

	added_node = Graph::Node.new(id)
	@nodes <<  added_node
	
	return added_node
end


def get_node(id)
	return @nodes.select{|node| node.id === id}
end


def validate()
	mark_and_sweep(1)

	if @mark.count != @nodes.count
		raise
	end
end


# 直感的にはうまくいきそうと思うものの、不足なく周回でき、かつ終了できないみたいな状態に陥らない保障が取りきれてない
def mark_and_sweep(id)
	current = get_node(id)

	mark = @marks.select {|markid| markid === id}
	if mark.empty?
		@marks << id
	end
	
	if !current.go.empty? && @marks.select {|a| a === go[0][1]}.empty?
		nextid = current.go[0]
	elsif !current.go.empty? && !current.go[1].nil? && @marks.select {|markid| markid === go[1]}.empty?
		nextid = current.go[1]
	elsif !current.back.empty? 
		if !@marks.select {|markid| markid === current.back[0]}.empty? && !current.back[1].nil?
			nextid = current.back[1] 
		else
			nextid = current.back[0]
		end
	else
		return #ここにくるのはスタート地点（[0,0]に戻ってきてかつ右も下もmark済のときのみ。）
	end

	mark_and_sweep(nextid)
end


class Node
	def initialize(id)
		@id = id
		@go = []
		@back = []
	end
	attr_reader :id, :go, :back
end


end
