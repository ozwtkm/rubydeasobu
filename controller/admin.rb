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
	aisles= JSON.parse(@req.body)
	dangeon_id = @URLquery[0].to_i
	floor =  @URLquery[1].to_i

	graph = Graph.new(aisles)
	graph.validate()
	
	map = Map.create(aisles)
	map.save(dangeon_id,floor)
end


end


