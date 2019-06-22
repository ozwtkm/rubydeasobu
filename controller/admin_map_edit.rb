#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'json'
require_relative './_baseclass_require_admin'
require_relative '../model/map'
require_relative '../_util/graph_util'
require_relative '../exception/Error_0or1'

class Admin_map_edit_controller < Base_require_admin

def initialize(req, res)
	@template = "admin_map_edit.erb"
	super
end

def control()
	@aisles = JSON.parse(@req.body)
	check_aisle()
	aisles2 = @aisles.dup # 破壊的処理を2回やるので複製しとく
	
	dangeon_id = @URLquery[1].to_i
	z =  @URLquery[2].to_i # フロアのこと

	graph = Graph.new(@aisles)
	graph.validate()
	
	map = Map.create(aisles2)
	map.save(dangeon_id,z)
end

def check_aisle()
	@aisles.each do |row|
		if row.match(/\A[0,1]\z/).nil?
			raise Error_0or1.new("壁の値")
		end
	end
end

end


