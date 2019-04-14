#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_input_special_character < Base_exception

def initialize(key)

	super(412, "#{key}に特殊記号含めんな（/\A[a-zA-Z0-9_@]+\z/）")

end

end
