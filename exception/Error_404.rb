#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require_relative './baseclass_exception'

class Error_404 < Base_exception

def initialize

	super(404, "naiyo")

end

end