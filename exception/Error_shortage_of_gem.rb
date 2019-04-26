#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_shortage_of_gem < Base_exception

def initialize

	super(412, "gem足りねえよ貧乏人")

end

end