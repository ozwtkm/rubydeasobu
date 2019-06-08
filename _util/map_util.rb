#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

class Map_util
	UP = 1
	LEFT = 2
	DOWN = 4
	RIGHT = 8
	
	def initialize(side_refs, vertical_refs)
		@graph = Map_util::Graph.new
		@roomids = {}
		@side_refs = side_refs
		@vertical_refs = vertical_refs
	end
	attr_accessor :roomids, :graph
		
	def self.create(side_refs, vertical_refs)
		mapcreater = Map_util.new(side_refs, vertical_refs)
		
		mapcreater.create_rooms() #参照からへやつくる

		if mapcreater.roomids["0_0"].nil?
			raise # [0][0]はスタート地点として存在しなければならないとする
		end
		
		map = mapcreater.graph.get_map() # たどりながらnewしていき浮き島になってるroomを殺す
		# 浮き島が判明したとき、raiseしてもいいが、
		# 浮き島を除去した本島をそのまま返した方がシンプルでよいのではとおもっている。

		return map
	end

	def create_rooms()
		line = Float::INFINITY
		
		@vertical_refs.each.with_index do |row1,index1|
			if row1.count(1) === 0
				line = index1+1
				break
			end

			row1.each.with_index do |row2,index2|
				x = index2
				y = index1
				
				if row2.to_i === 1
					create_room(x,y,aisle: DOWN)
					create_room(x,y+1,aisle: UP)
					
					@graph.add_ref(@roomids[x.to_s + "_" + y.to_s], @roomids[x.to_s + "_" + (y+1).to_s])
				end
			end
		end
		
		
		@side_refs.each.with_index do |row1,index1|
			if index1 === line
				break
			end
		
			row1.each.with_index do |row2, index2|
				x=index2
				y=index1
			
				if row2.to_i === 1
					create_room(x,y,aisle: RIGHT)
					create_room(x+1,y,aisle: LEFT)
					
					@graph.add_ref(@roomids[x.to_s + "_" + y.to_s], @roomids[(x+1).to_s + "_" + y.to_s])
				end
			end
		end
	end


	def create_room(x,y,aisle: )
		if @roomids[x.to_s + "_" + y.to_s].nil?
			roomid = @graph.add_room(Map_util::Room.new(x,y))
			@roomids[x.to_s + "_" + y.to_s] = roomid
		else
			roomid = @roomids[x.to_s + "_" + y.to_s]
		end

		@graph.get_room(roomid).aisle += aisle
	end


class Room
	def initialize(x,y)
		@x=x
		@y=y
		@aisle=0
	end
	attr_accessor :aisle
	attr_reader :x, :y
end


class Graph
	def initialize()
		@seq = 1.step
		@rooms = {}
		@refs = []
		@marks = []
	end
	attr_accessor :rooms, :refs

	def add_room(roomobj)
		id = @seq.next
	
		@rooms[id] = roomobj

		return id
	end

	def add_ref(srcid,dstid)
		@refs << [srcid,dstid]
	end

	def get_room(id)
		return @rooms[id]
	end

	def get_map()
		mark_and_sweep(1)
		
		map = []
		@marks.each do |row|
			map << @rooms[row]
		end
		
		return map
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

end

end
