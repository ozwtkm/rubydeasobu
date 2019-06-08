#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/map'
require_relative '../_util/graph_util'

class Admin_controller < Base_require_login

def initialize(req, res)
	@template = "admin.erb"
	super
end

def control()
	#後々リクエストにダンジョンIDとフロア（z）も含める。
	# ↓リクエストで["1","1","3",["1","1","1","1","1","1","1","1","1","1","1","1"]]みたいなのくる
	data = JSON.parse(@req.body)
	
	dangeon_id = data[0].to_i
	floor =  data[1].to_i
	num = data[2].to_i
	aisles= data[3]
	
	if num < 2 || num > 100 # まあここは決めの問題ではある
		raise
	end
	
	require_refs_count = 2*num*(num-1)
	if aisles.count != require_refs_count
		raise
	end
	
	graph = Graph.new(aisles,num)
	map = graph.validate()
	
	Map.save_by_instance(map, dangeon_id, floor)
	
	#a =Map.get(@dangeon_id, @floor)
end




end


