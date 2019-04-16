#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_duplicate_id < Base_exception

def initialize()

	super(409, "キャラかぶりｗ")

end

end