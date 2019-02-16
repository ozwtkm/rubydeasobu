#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass'

class Index < Base

def initialize(req,res)

	@template = "index.erb"

	super

end


end