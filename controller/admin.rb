#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/dangeon'
require_relative '../util/maze'

class Admin_controller < Base_require_login

def initialize(req, res)
	@template = "admin.erb"
	super
end

def control()
	#後々リクエストにダンジョンIDとフロア（z）も含める。
	# ↓リクエストで["3",{"1","1","1","1","1","1","1","1","1","1","1","1"}]みたいなのくる
	data = JSON.parse(@req.body)
	
	@num = data[0].to_i
	@refs= data[1].to_i
	@dangeon_id = dataからとってくる
	@side_refs = []
	@vertical_refs = []
	require_refs_count = 2*n*(n-1)
	
	if @refs.count != require_refs_count
		raise
	end

	shape_refs

	maps = Map.create(@side_refs,@vertical_refs,@num) # Maputilの中のcreate関数にmarkandsweepとmapobj生成がらっぷされる
	
	maps.each do |row|
		Dangeon.add_map(@dangeon_id, row.x, row.y, row.z, row.aisle)
	end

end


#スマートなやり方あとで考える
def shape_refs
	line=0
	num-1.times do
			num-1.times do 
				@side_refs[line].push(refs.shift)
			end
			
			num.times do
				@vertical_refs[line].push(refs.shift)
			end
			
			line+=1
	end
	
	num-1.times do
		@side_refs[line].push(refs.shift)
	end
	
	if @side_refs[line].nil? || !@refs.last.nil?
		raise
	end
	
end

end


