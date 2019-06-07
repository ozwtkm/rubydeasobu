#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/map'
require_relative '../util/map_util'

class Admin_controller < Base_require_login

def initialize(req, res)
	@template = "admin.erb"
	super
end

def control()
	#後々リクエストにダンジョンIDとフロア（z）も含める。
	# ↓リクエストで["3",{"1","1","1","1","1","1","1","1","1","1","1","1"}]みたいなのくる
	data = JSON.parse(@req.body)
	
	@num = data[0]
	@refs= data[1]
	@dangeon_id = dataからとってくる
	@side_refs = []
	@vertical_refs = []
	require_refs_count = 2*num*(num-1)
	
	if @refs.count != require_refs_count
		raise
	end

	shape_refs()

	map = Map_util.create(@side_refs,@vertical_refs) # Maputilの中のcreate関数にmarkandsweepとmapobj生成がらっぷされる
	
	Map.add_by_instance(map)
	
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


