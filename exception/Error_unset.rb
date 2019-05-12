#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_unset < Base_exception

def initialize(val)

	super(412, "#{val}がunsetやぞ")

end

end