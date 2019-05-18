#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_shortage_of_material < Base_exception

def initialize()

	super(412, "素材足らん")

end

end