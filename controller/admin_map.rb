#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'json'
require_relative './_baseclass_require_admin'
require_relative '../model/map'
require_relative '../_util/graph_util'
require_relative '../exception/Error_0or1'

class Admin_map_controller < Base_require_admin
	CREATED = 201

def initialize(req, res)
	@template = "admin_map.erb"
	super
end

# put（更新）も兼ねてる
def post_control()
	@aisles = JSON.parse(@req.body)
	check_aisle()

	dangeon_id = @URLquery[1].to_i
	z =  @URLquery[2].to_i # フロアのこと

	# 1 dupしてるのは@aislesに破壊処理が2回走るから
	# 2 graphの正当性検証もnewの中で行われる
	graph = Graph.new(@aisles.dup) 
	
	map = Map.create(@aisles,dangeon_id,z)
	map.save()

	@res.status = CREATED
end

def check_aisle()
	if !@aisles.all?{|x| [0,1].include?(x)}
		raise Error_0or1.new("壁の値")
	end
end

end


