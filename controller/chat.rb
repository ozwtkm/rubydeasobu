#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative '../baseclass'
	
class Chat < Base

def initialize(req,res)

	@template = "websocket.erb"

	super
	
end

end
