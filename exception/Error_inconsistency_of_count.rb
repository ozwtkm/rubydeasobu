#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_inconsistency_of_count < Base_exception

def initialize(key)

	super(412, key+"の個数がおかしい")

end

end