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

	dangeon_id = @URLquery[1].to_i
	z =  @URLquery[2].to_i # フロアのこと

	graph = Graph.new(@aisles.dup) #graphの正当性検証もnewの中で行われる
	
	map = Map.create(@aisles,dangeon_id,z)
	map.save()
end

def check_aisle()
	if !@aisles.all?{|x| ["0","1"].include?(x)}
		raise Error_0or1.new("壁の値")
	end
end

end


