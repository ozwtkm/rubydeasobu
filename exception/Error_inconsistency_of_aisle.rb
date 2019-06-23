#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_inconsistency_of_aisle < Base_exception

def initialize(invalid_start: false)
	if invalid_start
		msg = "スタート地点セットしろ"
	else
		msg = "aisleがおかしい" 
	end

	super(412, msg)
end

end