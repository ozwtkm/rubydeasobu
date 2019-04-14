#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_input_nil < Base_exception

def initialize(key)

	super(412, "#{key}がnilだよ")

end

end
