#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_0or1 < Base_exception

def initialize(key)

	super(412, key+"は0か1でよろ")

end

end