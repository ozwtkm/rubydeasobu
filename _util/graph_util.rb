#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Graph


def initialize(aisles)
	num = calc_one_side(aisles)

	@side_aisles = []
	@vertical_aisles = []
	shape_aisles(aisles,num)

	@seq_nodeid = 1.step
	@seq_markid = 1.step

	@relation = {} #mapにおけるroomに対応するNode。1roomに複数のNodeが対応する。
	@nodes = [] 
	@marks = {}
	
	create_nodes()
end

def calc_one_side(aisles)
	num = Math.sqrt(1+2*aisles.count)/2
	
	if num.ceil != num
		raise 
	end
	
	return num.to_i
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
	current = @relation[x.to_s + "_" + y.to_s]
	
	if current.nil?
		markid = set_mark(x,y)
		current = add_node(markid)
		@relation[x.to_s + "_" + y.to_s] << current
	end
	
	if vertical
		markid = set_mark(x,y+1)
		child = add_node(markid)
	
		current.each do |row|
			get_node(row).child_id = child.id
			@relation[x.to_s + "_" + (y+1).to_s] << child.id
		end
	elsif side
		markid = set_mark(x+1,y)
		child = add_node(markid)
	
		current.each do |row|
			get_node(row).child_id = child.id
			@relation[(x+1).to_s + "_" + y.to_s] << child.id
		end
	end
end

def set_mark(x,y)
	if @relation[x.to_s + "_" + y.to_s].nil?
		mark = add_mark()
	else
		mark = @relation[x.to_s + "_" + y.to_s].first.mark_id
	end
	
	return mark
end

def add_mark()
	id = @seq_markid.next
	@marks[id] = false
	
	return id
end

def add_node(markid)
	nodeid = @seq_nodeid.next

	added_node = Graph::Node.new(nodeid,markid)
	@nodes <<  added_node
	
	return added_node
end


def get_node(id)
	return @nodes.select{|node| node.id === id}
end


def validate()
	mark_and_sweep(1)

	if @marks.value?(false)
		raise
	end
end

#「mapの世界では同じroomを指す」が、graphの世界では親が異なるノードを別ノードとみなすと、
#二分木をつくることができ、マップの探索を二分木探索に帰着でき、問題が明るくなる。
#ただ計算量はえげつなくなる。(高さ2n-1の木になる)
#残念ながら指数関数オーダになるのでボツかな..
#しかし考察の余地はある？
#あくまでmarkを拾うのが目的だから探索途中で切り上げられるケースも多そうだし..
#幅優先探索にすれば早期に全markをたどれるかもとか
def mark_and_sweep(id)
	current = get_node(id)

	mark = @marks[current.mark_id]
	if !mark
		mark = true
	end
	
	current.child_id.each do |row|
		mark_and_sweep(row)
	end
end


class Node
	def initialize(id,mark_id)
		@id = id
		@mark_id = markid
		@child_id = []
	end
	attr_reader :id, :mark_id, :child_id 
end


end
