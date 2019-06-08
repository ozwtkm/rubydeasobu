#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/map'
require_relative '../_util/map_util'

class Admin_controller < Base_require_login

def initialize(req, res)
	@template = "admin.erb"
	super
end

def control()
	#後々リクエストにダンジョンIDとフロア（z）も含める。
	# ↓リクエストで["1","1","3",["1","1","1","1","1","1","1","1","1","1","1","1"]]みたいなのくる
	data = JSON.parse(@req.body)
	
	@dangeon_id = data[0].to_i
	@floor =  data[1].to_i
	@num = data[2].to_i
	@refs= data[3]

	@side_refs = [[]]
	@vertical_refs = [[]]
	require_refs_count = 2*@num*(@num-1)
	
	if @num < 2 || @num > 100 # まあここは決めの問題ではある
		raise
	end
	
	if @refs.count != require_refs_count
		raise
	end
	
	shape_refs()

	map = Map_util.create(@side_refs,@vertical_refs) # Maputilの中のcreate関数にmarkandsweepとmapobj生成がらっぷされる
	
	Map.add_by_instance(map, @dangeon_id, @floor)
	
	a =Map.get(@dangeon_id, @floor)
end


#スマートなやり方あとで考える
def shape_refs
	line=0

	(@num-1).times do
		(@num-1).times do 
			@side_refs[line].push(@refs.shift.to_i)
		end
		@num.times do
			@vertical_refs[line].push(@refs.shift.to_i)
		end
		
		line+=1
		@side_refs[line] = []
		@vertical_refs[line] = []
	end

	(@num-1).times do
		@side_refs[line].push(@refs.shift.to_i)
	end
	
	if @side_refs[line][@num-2].nil? || !@refs.last.nil?
		raise
	end
	
end

end


