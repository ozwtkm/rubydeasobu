#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './_baseclass'

class Index_controller < Base

def initialize(req,res)

	@template = "index.erb"

	super

end


end