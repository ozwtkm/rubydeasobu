#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'json'
require_relative './_baseclass_require_login'
require_relative '../model/dangeon'


class Dangeon_controller < Base_require_login

def initialize(req, res)
	@template = "dangeon.erb"
	super
    
    @dangeon = Dangeon.get_list()
end

def get_control()
    @context[:dangeons] = @dangeon
end

end